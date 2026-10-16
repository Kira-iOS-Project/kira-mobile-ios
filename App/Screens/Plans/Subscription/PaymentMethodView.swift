/**
 Metode Pembayaran (AKN-07d; board MetodePembayaran): QRIS or App Store, Batal or Simpan. Saving
 closes the page.
 */
import Domain
import Features
import SwiftUI

struct PaymentMethodView: View {
    @State private var model: PaymentMethodModel
    private let onSaved: () -> Void
    @Environment(\.dismiss) private var dismiss

    init(current: PaymentMethod?, service: any PlansService, onSaved: @escaping () -> Void) {
        _model = State(initialValue: PaymentMethodModel(current: current, service: service))
        self.onSaved = onSaved
    }

    var body: some View {
        PlansScreenFrame {
            KiraNavBar("method.title", leading: .back("method.back") { dismiss() })
            PlansHeader("method.title", subtitle: "method.lede")
            PaymentMethodRows(title: "method.options", selection: $model.paymentMethod)
            KiraNotice(.info, title: "plans.prototype", message: "method.prototype")
            if case .failed(let problem) = model.phase { PlansProblemNotice(problem: problem) }
            PlansButtonRow(
                secondary: KiraButton("method.cancel", variant: .secondary, size: .small) { dismiss() },
                primary: KiraButton("method.save", size: .small) { Task { await model.save() } }
            )
            .disabled(isSaving)
        }
        .onChange(of: isSaved) { _, saved in
            guard saved else { return }
            onSaved()
            dismiss()
        }
    }

    private var isSaving: Bool {
        if case .saving = model.phase { return true }
        return false
    }

    private var isSaved: Bool {
        if case .saved = model.phase { return true }
        return false
    }
}
