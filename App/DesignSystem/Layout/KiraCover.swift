/**
 The window-wide layer under KiraDialog and the Kira sheet: a transparent full-screen cover that
 comes up and goes without the cover's own slide, so the dialog or the sheet animates itself over
 the `scrim`. Wherever it is attached, it covers the nav bar and the dock, the screen behind cannot
 be touched, and VoiceOver stays inside it.
 */
import SwiftUI

extension View {
    /**
     Shows `cover` over the window while `isPresented` is true. The cover animates its own content
     out when `isPresented` turns false, then calls the closure it is given to take the layer down;
     `onDismiss` runs once the layer is down, when another cover may come up.
     */
    func kiraCover<Cover: View>(
        isPresented: Binding<Bool>, onDismiss: (() -> Void)? = nil,
        @ViewBuilder cover: @escaping (_ onGone: @escaping () -> Void) -> Cover
    ) -> some View {
        modifier(CoverPresenter(isPresented: isPresented, onDismiss: onDismiss, cover: cover))
    }
}

/** Puts the layer up as soon as it is asked for, and down once its content has gone. */
private struct CoverPresenter<Cover: View>: ViewModifier {
    @Binding var isPresented: Bool
    let onDismiss: (() -> Void)?
    let cover: (_ onGone: @escaping () -> Void) -> Cover
    @State private var isCovering = false

    func body(content: Content) -> some View {
        content
            /**
             A clear cover leaves the screen behind in the window, and in reach of VoiceOver and the
             accessibility audit (the Utang step's chips above Tambah Rincian Utang): hidden while it is up.
             */
            .accessibilityHidden(isCovering)
            .onChange(of: isPresented, initial: true) { _, presented in
                if presented { setCovering(true) }
            }
            .fullScreenCover(isPresented: $isCovering, onDismiss: onDismiss) {
                cover { setCovering(false) }
                    .presentationBackground(.clear)
                    /** Taken down another way (a `dismiss()` inside it): the flag follows. */
                    .onDisappear { if isPresented { isPresented = false } }
            }
    }

    private func setCovering(_ covering: Bool) {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) { isCovering = covering }
    }
}
