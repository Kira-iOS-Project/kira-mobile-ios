/**
 What Kira Peduli opens over the Catat chat: the help sheet (PED-03), Check-in Lanjutan (PED-05)
 as a full screen, and the dialog of a check-in that could not be scheduled. The dialog waits until
 the check-in's screen is down, and its Coba Lagi brings the screen back once the dialog is down,
 with the person's choice kept (the owner's rule for a failed submit).
 */
import Domain
import Features
import SwiftUI

struct CareChatOverlays: ViewModifier {
    @Bindable var model: CareChatModel
    let care: any CareService
    let onOpen: (AppRoute) -> Void
    @State private var showsFailure = false
    @State private var retries = false

    func body(content: Content) -> some View {
        content
            .careHelpSheet(
                isPresented: $model.isHelpPresented, service: care, onOpen: onOpen, onClose: model.helpClosed
            )
            .fullScreenCover(
                /** Only the screen's own buttons close it: a full-screen cover has no swipe. */
                isPresented: Binding(get: { model.checkIn != nil }, set: { _ in }),
                onDismiss: checkInClosed,
                content: {
                    if let checkIn = model.checkIn { CheckInScreen(model: checkIn) }
                }
            )
            .kiraDialog(isPresented: $showsFailure, onDismiss: closeFailure) { failureDialog }
    }

    private var failureDialog: KiraDialog {
        KiraDialog(
            "care.checkIn.failedTitle", message: (model.checkInFailure?.failure ?? .connection).recordMessage,
            art: .failure, primary: KiraButton("care.checkIn.retry") { retries = true },
            secondary: KiraButton("ds.close", variant: .secondary) { retries = false })
    }

    /** The check-in's screen is down: the failure dialog, when scheduling failed. */
    private func checkInClosed() {
        showsFailure = model.checkInFailure != nil
    }

    private func closeFailure() {
        if retries {
            retries = false
            model.retryCheckIn()
        } else {
            model.checkInFailure = nil
        }
    }
}
