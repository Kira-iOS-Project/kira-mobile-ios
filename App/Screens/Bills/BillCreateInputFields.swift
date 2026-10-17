import Domain
import Features
import SwiftUI

/** The bill's name and whole-rupiah amount. */
struct BillCreateInputFields: View {
    @Bindable var model: BillCreateModel

    var body: some View {
        VStack(spacing: KiraSpacing.space4) {
            KiraField("bills.create.name", text: $model.name, prompt: "bills.create.name.prompt")
                .error(model.nameError)
            KiraField("bills.create.amount", text: $model.amountText, prompt: "bills.create.amount.prompt")
                .amount().prefix("wallet.currency").suffix("wallet.cents").error(model.amountError)
                .keyboardType(.numberPad)
        }
    }
}
