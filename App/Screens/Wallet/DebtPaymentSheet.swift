import APIClient
import Features
import SwiftUI

struct DebtPaymentSheet: View {
    @Bindable var model: DebtDetailModel
    let cancel: () -> Void
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        ScrollView {
            VStack(spacing: KiraSpacing.space4) {
                amountField
                if let problem = model.paymentProblem { WalletPaymentProblem(problem: problem) }
            }
        }
        .scrollBounceBehavior(.basedOnSize)
        .safeAreaInset(edge: .bottom, spacing: 0) { actions.padding(.bottom, KiraSpacing.space2) }
    }

    private var amountField: some View {
        KiraField("wallet.payment.amount", text: $model.amountText, prompt: "wallet.create.amount.prompt")
            .amount().prefix("wallet.currency").suffix("wallet.cents")
            .error(model.showsPaymentErrors && !model.canPay ? "wallet.payment.amount.invalid" : nil)
            .keyboardType(.numberPad)
    }

    @ViewBuilder private var actions: some View {
        let secondary = KiraButton("wallet.payment.cancel", variant: .secondary, action: cancel)
        let primary = KiraButton("wallet.payment.save") { Task { await model.pay() } }
        if typeSize.isAccessibilitySize {
            KiraButtonPair(secondary: secondary, primary: primary).disabled(model.isPaying)
        } else {
            WeightedRow(weights: [1, 1.3], spacing: KiraSpacing.space2) {
                secondary.block()
                primary.block()
            }.disabled(model.isPaying)
        }
    }
}

private struct WalletPaymentProblem: View {
    let problem: AppProblem

    var body: some View {
        VStack(alignment: .leading, spacing: KiraSpacing.space1) {
            KiraNotice(.warning, title: "wallet.payment.failed.title", message: problem.message)
            if problem.knownCode == nil { Text(problem.reference).font(.footnote).foregroundStyle(.inkMuted) }
        }
    }
}
