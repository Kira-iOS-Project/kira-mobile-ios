/**
 How a KiraDialog appears: in a KiraCover over the whole window, nav bar and dock included, on the
 `scrim`; the card fades in, growing a little unless Reduce Motion is on, and has no shadow. The
 screen behind cannot be touched, and VoiceOver stays in the dialog, starting on its title.
 Every button closes the dialog after its own action, as an alert's buttons do, and VoiceOver's
 escape gesture runs the secondary action (or the only one) and closes it too.
 */
import SwiftUI

extension View {
    /**
     Presents `dialog` over the window while `isPresented` is true. Its buttons and the escape
     gesture set `isPresented` back to false after their action; `onDismiss` runs once the
     dialog's layer is down.
     */
    func kiraDialog(
        isPresented: Binding<Bool>, onDismiss: (() -> Void)? = nil, dialog: @escaping () -> KiraDialog
    ) -> some View {
        kiraCover(isPresented: isPresented, onDismiss: onDismiss) { onGone in
            DialogCover(isPresented: isPresented, dialog: dialog, onGone: onGone)
        }
    }
}

/**
 The scrim and the card inside the cover: they fade in once the cover is up, and out before it
 goes. The card sits in the middle of the window and scrolls when the largest text sizes make it
 taller than the window.
 */
private struct DialogCover: View {
    @Binding var isPresented: Bool
    let dialog: () -> KiraDialog
    let onGone: () -> Void
    @State private var isShown = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            if isShown {
                Color.scrim
                    .ignoresSafeArea()
                    .accessibilityHidden(true)
                    .transition(.opacity)
                GeometryReader { window in
                    /**
                     Centred on the whole screen as `.k-dialog-scrim` centres it, not on the safe area,
                     which sits 12.5 pt lower (the 59 pt top inset against the 34 pt bottom one).
                     */
                    let lift = max(0, window.safeAreaInsets.top - window.safeAreaInsets.bottom)
                    ScrollView {
                        dialog()
                            .presented { isPresented = false }
                            .padding(.horizontal, KiraSpacing.space6)
                            .padding(.vertical, KiraSpacing.space4)
                            .frame(minHeight: max(0, window.size.height - lift))
                            .padding(.bottom, lift)
                    }
                    .scrollBounceBehavior(.basedOnSize)
                    .withoutScrollEdgeEffect()
                }
                .transition(reduceMotion ? .opacity : .opacity.combined(with: .scale(scale: 0.96)))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear { show(isPresented) }
        .onChange(of: isPresented) { _, presented in show(presented) }
    }

    private func show(_ presented: Bool) {
        withAnimation(.easeOut(duration: reduceMotion ? 0.15 : 0.2)) {
            isShown = presented
        } completion: {
            /** Asked for again while fading out: the cover stays. */
            if !isPresented { onGone() }
        }
    }
}

extension View {
    /** No blur at a scroll view's edges (iOS 26): the scrim stays one even colour behind the card. */
    @ViewBuilder
    func withoutScrollEdgeEffect() -> some View {
        if #available(iOS 26, *) {
            scrollEdgeEffectHidden(true, for: .vertical)
        } else {
            self
        }
    }
}
