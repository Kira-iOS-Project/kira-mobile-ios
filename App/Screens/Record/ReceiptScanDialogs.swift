/**
 Why a scan stopped: the camera could not be used, the receipt could not be read (CAT-06: "gagal
 baca → ajak foto ulang atau Ketik Manual"), or sending its text failed.
 */
import Domain
import Features
import SwiftUI

struct ReceiptScanDialogs: ViewModifier {
    @Bindable var model: ReceiptScanModel

    func body(content: Content) -> some View {
        content
            .kiraDialog(isPresented: binding(.camera)) {
                KiraDialog(
                    "record.scan.cameraTitle", message: "record.scan.cameraBody", art: .illustration(.padlock),
                    primary: KiraButton("ds.close", variant: .secondary) {})
            }
            .kiraDialog(isPresented: binding(.unreadable)) {
                KiraDialog(
                    "record.scan.unreadableTitle", message: "record.scan.unreadableBody", art: .illustration(.receipt),
                    primary: KiraButton("record.scan.retake", action: model.retake),
                    secondary: KiraButton("record.scan.manualLong", variant: .secondary, action: model.typeManually))
            }
            .recordFailureDialog(
                Binding(
                    get: {
                        if case .failed(let failure) = model.problem { return failure }
                        return nil
                    },
                    set: { if $0 == nil { model.problem = nil } }))
    }

    private func binding(_ problem: ReceiptScanModel.Problem) -> Binding<Bool> {
        Binding(get: { model.problem == problem }, set: { if !$0 { model.problem = nil } })
    }
}
