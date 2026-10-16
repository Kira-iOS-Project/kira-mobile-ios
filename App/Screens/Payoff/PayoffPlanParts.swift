/**
 The parts of Rencanaku below the progress bar: the payment to make next, the plan's accounts in
 the order it pays them, the debts it leaves alone, and the card that says every account is paid.
 */
import Domain
import Features
import SwiftUI

/** The payment due next, with Tandai Sudah Bayar. */
struct PayoffNextPaymentCard: View {
    let payment: NextPayment
    let isWorking: Bool
    let onPaid: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: KiraSpacing.space3) {
            VStack(alignment: .leading, spacing: KiraSpacing.space1) {
                Text("plan.next.title")
                    .font(.subheadline.weight(.semibold)).kiraLineHeight(20, size: 15).foregroundStyle(.inkMuted)
                Text(payment.name).kiraFont(.title).foregroundStyle(.ink)
                KiraAmount(Decimal(payment.amount), size: .large)
                if let due = PayoffPlanCopy.due(payment) {
                    Text(due).font(.footnote).kiraLineHeight(18, size: 13).foregroundStyle(.inkMuted)
                }
            }
            .accessibilityElement(children: .combine)
            KiraButton("plan.pay", action: onPaid).icon(.check).block()
                .disabled(isWorking)
        }
        .padding(KiraSpacing.space4)
        .frame(maxWidth: .infinity, alignment: .leading)
        .kiraCard()
    }
}

/** Every consumer account is paid: the plan is done, and the way to the score. */
struct PayoffPlanDoneCard: View {
    let onScore: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: KiraSpacing.space3) {
            KiraIllustration(.bloom, size: 96)
            Text("plan.done.title").kiraFont(.title).foregroundStyle(.ink)
            Text("plan.done.body").kiraFont(.callout).foregroundStyle(.inkMuted)
            KiraButton("plan.done.cta", action: onScore).block()
        }
        .padding(KiraSpacing.space4)
        .frame(maxWidth: .infinity, alignment: .leading)
        .kiraCard()
    }
}

/** The consumer accounts: the one in progress and those that follow, which can take its place. */
struct PayoffPlanAccounts: View {
    let model: PayoffPlanModel
    let plan: ActivePayoffPlan

    var body: some View {
        KiraListGroup("plan.accounts.title", footer: "plan.accounts.footer") {
            ForEach(plan.consumerAccounts, id: \.id) { account in
                KiraListRow(
                    Text(account.name), leading: .category(account.kind.category),
                    trailing: account.status == .next ? .chevron : .none,
                    action: account.status == .next ? { Task { await model.focus(on: account.id) } } : nil
                ) {
                    KiraTag(
                        PayoffPlanCopy.tag(account.status), tone: account.status == .inProgress ? .pandan : .neutral)
                }
                .subtitle(Text(PayoffPlanCopy.progress(account)))
                .amount(KiraAmount(Decimal(account.remaining)))
            }
        }
    }
}

/** Vehicle, home and family loans: paid as usual, and out of the plan. */
struct PayoffOngoingList: View {
    let accounts: [PlanAccount]

    var body: some View {
        KiraListGroup("plan.ongoing.title", footer: "plan.ongoing.footer") {
            ForEach(accounts, id: \.id) { account in
                KiraListRow(Text(account.name), leading: .category(account.kind.category), trailing: .none) {
                    KiraTag(PayoffPlanCopy.tag(account.status))
                }
                .subtitle(Text(PayoffPlanCopy.progress(account)))
                .amount(KiraAmount(Decimal(account.remaining)))
            }
        }
    }
}
