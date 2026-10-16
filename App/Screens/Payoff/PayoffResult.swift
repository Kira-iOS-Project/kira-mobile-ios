/**
 What the plan comes to: when everything is paid off and at what interest, the comparison with
 the other method (SKR-03c), the order of the accounts, and the debts the plan leaves alone.
 */
import Domain
import SwiftUI

/** The plan's numbers below the inputs. */
struct PayoffResult: View {
    let simulation: PayoffSimulation

    var body: some View {
        VStack(alignment: .leading, spacing: KiraSpacing.space5) {
            PayoffSummaryCard(simulation: simulation)
            if let comparison = simulation.comparison {
                PayoffComparisonNotice(comparison: comparison)
            }
            if simulation.hasUnknownRate {
                KiraNotice(.info, title: "payoff.unknownRate.title", message: "payoff.unknownRate.body")
            }
            PayoffOrderList(accounts: simulation.accounts)
            if !simulation.productive.isEmpty {
                PayoffProductiveList(debts: simulation.productive)
            }
            KiraNotice(.simulation, title: "payoff.simulation.title", message: "payoff.simulation.body")
        }
    }
}

/** When the last account is paid off, what it costs in interest and what the plan pays each month. */
private struct PayoffSummaryCard: View {
    let simulation: PayoffSimulation

    var body: some View {
        VStack(alignment: .leading, spacing: KiraSpacing.space2) {
            if let month = PayoffCopy.month(simulation.allPaidMonth) {
                Text("payoff.summary.allPaid \(month)").kiraFont(.title).foregroundStyle(.ink)
            } else {
                Text("payoff.summary.notAll").kiraFont(.title).foregroundStyle(.ink)
            }
            if let interest = simulation.totalInterest {
                Text("payoff.summary.interest \(PayoffCopy.rupiah(interest))")
            }
            Text("payoff.summary.budget \(PayoffCopy.rupiah(simulation.monthlyBudget))")
        }
        .font(.subheadline).kiraLineHeight(20, size: 15).foregroundStyle(.inkMuted)
        .padding(KiraSpacing.space4)
        .frame(maxWidth: .infinity, alignment: .leading)
        .kiraCard()
        .accessibilityElement(children: .combine)
    }
}

/** The chosen method against the other: the interest and the first payoff. */
private struct PayoffComparisonNotice: View {
    let comparison: PayoffComparison

    var body: some View {
        VStack(alignment: .leading, spacing: KiraSpacing.space2) {
            KiraNotice(.info, title: "payoff.compare.title", message: PayoffCopy.interest(comparison.interest))
            if let first = PayoffCopy.firstPayoff(comparison.firstPayoff) {
                Text(first)
                    .font(.footnote).kiraLineHeight(18, size: 13).foregroundStyle(.inkMuted)
                    .padding(.horizontal, KiraSpacing.space1)
            }
        }
    }
}

/** The consumer accounts in the order the plan pays them. */
private struct PayoffOrderList: View {
    let accounts: [PayoffAccount]

    var body: some View {
        KiraListGroup("payoff.order.title", footer: "payoff.order.footer") {
            ForEach(accounts, id: \.id) { account in
                KiraListRow(
                    Text(account.name), leading: .category(account.kind.category), trailing: .none, action: nil
                ) {
                    KiraTag(tag(of: account), tone: account.position == 1 ? .pandan : .neutral)
                }
                .subtitle(when(account))
                .amount(KiraAmount(Decimal(account.remaining)))
            }
        }
    }

    private func tag(of account: PayoffAccount) -> LocalizedStringResource {
        account.position == 1 ? "payoff.tag.first" : "payoff.tag.next"
    }

    private func when(_ account: PayoffAccount) -> Text {
        guard let month = PayoffCopy.month(account.payoffMonth), let months = account.months else {
            return Text("payoff.account.never")
        }
        return Text("payoff.account.when \(month) \(months)")
    }
}

/** Vehicle, home and family loans: listed, paid as usual, and out of the plan. */
private struct PayoffProductiveList: View {
    let debts: [ProductiveDebt]

    var body: some View {
        KiraListGroup("payoff.productive.title", footer: "payoff.productive.footer") {
            ForEach(debts, id: \.id) { debt in
                KiraListRow(Text(debt.name), leading: .category(debt.kind.category), trailing: .none, action: nil) {
                    Text("payoff.productive.instalment \(PayoffCopy.rupiah(debt.monthlyInstalment))")
                        .font(.footnote).kiraLineHeight(18, size: 13).foregroundStyle(.inkMuted)
                }
                .amount(KiraAmount(Decimal(debt.remaining)))
            }
        }
    }
}
