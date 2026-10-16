/**
 Sheet (design system: `.k-sheet`): a sheet that rises over the current screen, which stays visible
 above it under the `scrim`, so the person keeps their place: editing a draft, changing a category,
 picking a date, confirming an outside link, community rules, and the Kira Peduli help (the chat
 stays open behind it). It is the design system's sheet, not the system one: the `surface` panel
 from just under the status bar to the bottom edge, 30 pt top corners with a hairline along the
 top, a line-strong grabber at half opacity, and a header with the title centred and the close X
 on the right, styled like a secondary button. Swiping the grabber or the header down, tapping the
 scrim, the X and VoiceOver's escape gesture close it. The main action goes at the bottom.
 */
import SwiftUI

extension View {
    /** Presents `content` as a Kira sheet over the window while `isPresented` is true. */
    func kiraSheet<Content: View>(
        isPresented: Binding<Bool>, title: LocalizedStringResource, subtitle: LocalizedStringResource? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        kiraCover(isPresented: isPresented) { onGone in
            SheetCover(isPresented: isPresented, title: title, subtitle: subtitle, onGone: onGone, content: content)
        }
    }
}

/** The scrim and the panel: the scrim fades in as the panel rises, and both go before the cover. */
private struct SheetCover<Content: View>: View {
    @Binding var isPresented: Bool
    let title: LocalizedStringResource
    let subtitle: LocalizedStringResource?
    let onGone: () -> Void
    @ViewBuilder let content: () -> Content
    @State private var isShown = false
    @State private var drag: CGFloat = 0
    @AccessibilityFocusState private var titleFocused: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack(alignment: .bottom) {
            if isShown {
                Color.scrim
                    .ignoresSafeArea()
                    .onTapGesture { isPresented = false }
                    .accessibilityHidden(true)
                    .transition(.opacity)
                panel
                    .offset(y: max(drag, 0))
                    .transition(reduceMotion ? .opacity : .move(edge: .bottom))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .onAppear { show(isPresented) }
        .onChange(of: isPresented) { _, presented in show(presented) }
    }

    private var shape: UnevenRoundedRectangle {
        UnevenRoundedRectangle(topLeadingRadius: KiraRadius.extraLarge, topTrailingRadius: KiraRadius.extraLarge)
    }

    private var panel: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                Capsule().fill(.lineStrong).opacity(0.5).frame(width: 36, height: 5).padding(.bottom, 6)
                header.padding(.bottom, KiraSpacing.space4)
            }
            .contentShape(Rectangle())
            .gesture(dragToClose)
            VStack(spacing: KiraSpacing.space4) { content() }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .padding(.top, KiraSpacing.space2)
        .padding(.horizontal, KiraSpacing.space4)
        .background {
            shape.fill(.surface).ignoresSafeArea(edges: .bottom)
        }
        .overlay {
            /** `border-top: 1px solid hairline`: the stroke fades out down the rounded corners. */
            shape.stroke(.hairline, lineWidth: 1)
                .mask(LinearGradient(colors: [.black, .clear], startPoint: .top, endPoint: .init(x: 0.5, y: 0.05)))
                .ignoresSafeArea(edges: .bottom)
        }
        .accessibilityElement(children: .contain)
        .accessibilityAction(.escape) { isPresented = false }
    }

    private var header: some View {
        HStack(spacing: KiraSpacing.space4) {
            Color.clear.frame(width: KiraSize.tap, height: KiraSize.tap)
            VStack(spacing: 0) {
                Text(title)
                    .font(.headline).kiraLineHeight(22, size: 17)
                    .foregroundStyle(.ink)
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityFocused($titleFocused)
                if let subtitle {
                    Text(subtitle).font(.caption).kiraLineHeight(16, size: 12).foregroundStyle(.inkMuted)
                }
            }
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            KiraIconButton.close { isPresented = false }
        }
    }

    /** Down past 120 pt, or flicked down, closes the sheet; anything less springs back. */
    private var dragToClose: some Gesture {
        DragGesture()
            .onChanged { value in drag = value.translation.height }
            .onEnded { value in
                if value.translation.height > 120 || value.predictedEndTranslation.height > 300 {
                    isPresented = false
                } else {
                    withAnimation(.spring(duration: 0.3, bounce: 0)) { drag = 0 }
                }
            }
    }

    private func show(_ presented: Bool) {
        withAnimation(reduceMotion ? .easeOut(duration: 0.15) : .spring(duration: 0.35, bounce: 0)) {
            isShown = presented
        } completion: {
            if presented {
                titleFocused = true
            } else if !isPresented {
                drag = 0
                onGone()
            }
        }
    }
}
