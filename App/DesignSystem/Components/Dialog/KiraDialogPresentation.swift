// How a KiraDialog appears: over the whole window, nav bar and dock included, on the `scrim`; the
// card fades in, growing a little unless Reduce Motion is on, and has no shadow. It sits in a
// full-screen cover that comes up without the sheet's slide, wherever the modifier is attached, so
// the screen behind cannot be touched and VoiceOver stays in the dialog, starting on its title.
// Every button closes the dialog after its own action, as an alert's buttons do, and VoiceOver's
// escape gesture runs the secondary action (or the only one) and closes it too.
import SwiftUI

extension View {
    /// Presents `dialog` over the window while `isPresented` is true. Its buttons and the escape
    /// gesture set `isPresented` back to false after their action.
    func kiraDialog(isPresented: Binding<Bool>, dialog: @escaping () -> KiraDialog) -> some View {
        modifier(DialogPresenter(isPresented: isPresented, dialog: dialog))
    }
}

/// Puts the cover up as soon as the dialog is asked for, and takes it down once the dialog has
/// faded out, both without the cover's own animation.
private struct DialogPresenter: ViewModifier {
    @Binding var isPresented: Bool
    let dialog: () -> KiraDialog
    @State private var isCovering = false

    func body(content: Content) -> some View {
        content
            .onChange(of: isPresented, initial: true) { _, presented in
                if presented { setCovering(true) }
            }
            .fullScreenCover(isPresented: $isCovering) {
                DialogCover(isPresented: $isPresented, dialog: dialog) { setCovering(false) }
                    .presentationBackground(.clear)
            }
    }

    private func setCovering(_ covering: Bool) {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) { isCovering = covering }
    }
}

/// The scrim and the card inside the cover: they fade in once the cover is up, and out before it
/// goes. The card sits in the middle of the window and scrolls when the largest text sizes make it
/// taller than the window.
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
                    ScrollView {
                        dialog()
                            .presented { isPresented = false }
                            .padding(.horizontal, KiraSpacing.space6)
                            .padding(.vertical, KiraSpacing.space4)
                            .frame(minHeight: window.size.height)
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
            // Asked for again while fading out: the cover stays.
            if !isPresented { onGone() }
        }
    }
}

extension View {
    /// No blur at a scroll view's edges (iOS 26): the scrim stays one even colour behind the card.
    @ViewBuilder
    fileprivate func withoutScrollEdgeEffect() -> some View {
        if #available(iOS 26, *) {
            scrollEdgeEffectHidden(true, for: .vertical)
        } else {
            self
        }
    }
}
