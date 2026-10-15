/**
 Sheet (design system): a sheet that rises over the current screen, which stays visible above it
 under the scrim, so the person keeps their place: editing a draft, changing a category, picking
 a date, confirming an outside link, community rules, and the Kira Peduli help (the chat stays
 open behind it). The close X sits on the right of the header, styled like a secondary button;
 swiping down closes it too. The main action goes at the bottom.
 */
import SwiftUI

extension View {
    /**
     Presents `content` as a Kira sheet: medium and large detents, a grabber, the `surface`
     background with 30 pt corners, and a header with the title and the close button.
     */
    func kiraSheet<Content: View>(
        isPresented: Binding<Bool>, title: LocalizedStringResource, subtitle: LocalizedStringResource? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        sheet(isPresented: isPresented) {
            KiraSheetBody(title: title, subtitle: subtitle, content: content())
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                .presentationBackground(.surface)
                .presentationCornerRadius(KiraRadius.extraLarge)
        }
    }
}

/** A sheet's header and body. */
private struct KiraSheetBody<Content: View>: View {
    let title: LocalizedStringResource
    let subtitle: LocalizedStringResource?
    let content: Content
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: KiraSpacing.space4) {
            HStack(spacing: KiraSpacing.space4) {
                Color.clear.frame(width: KiraSize.tap, height: KiraSize.tap)
                VStack(spacing: 0) {
                    Text(title).font(.headline).foregroundStyle(.ink).accessibilityAddTraits(.isHeader)
                    if let subtitle { Text(subtitle).font(.caption).foregroundStyle(.inkMuted) }
                }
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                KiraIconButton.close { dismiss() }
            }
            VStack(spacing: KiraSpacing.space4) { content }
                .frame(maxHeight: .infinity, alignment: .top)
        }
        .padding(.horizontal, KiraSpacing.space4)
        .padding(.top, KiraSpacing.space5)
        .padding(.bottom, KiraSpacing.space2)
    }
}

#if DEBUG
    #Preview { GalleryNavigation().galleryPage() }
#endif
