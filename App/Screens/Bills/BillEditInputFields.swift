import Domain
import Features
import SwiftUI

/** The bill name and whole-rupiah amount. */
struct BillEditInputFields: View {
    @Bindable var model: BillEditModel

    var body: some View {
        VStack(spacing: KiraSpacing.space4) {
            KiraField("bills.edit.name", text: name, prompt: "bills.edit.name.prompt")
                .error(model.nameError)
            KiraField("bills.edit.amount", text: amount, prompt: "bills.edit.amount.prompt")
                .error(model.amountError)
                .amount().prefix("wallet.currency").suffix("wallet.cents")
                .keyboardType(.numberPad)
        }
    }

    private var name: Binding<String> {
        Binding(get: { model.draft?.name ?? "" }, set: { model.draft?.name = $0 })
    }

    private var amount: Binding<String> {
        Binding(get: { model.draft?.amountText ?? "" }, set: { model.draft?.amountText = $0 })
    }
}
