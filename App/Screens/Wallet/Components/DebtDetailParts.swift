/**
 The parts of Detail Utang (board DetailUtang): the remaining amount with the paid share, Rincian,
 Langkah Berikutnya and Riwayat Pembayaran.
 */
import Domain
import Features
import SwiftUI

/** Sisa utang beside the debt's icon, then Sudah dibayar as a ribbon over the total. */
struct DebtSummaryCard: View {
    let debt: DebtDetail

    var body: some View {
        VStack(alignment: .leading, spacing: KiraSpacing.space4) {
            HStack(spacing: 14) {
                KiraCategoryIcon(debt.kind.category, size: 52).accessibilityHidden(true)
                VStack(alignment: .leading, spacing: KiraSpacing.space1) {
                    Text("debt.detail.remaining").kiraFont(.overline).foregroundStyle(.inkMuted)
                    KiraAmount(debt.remaining.rupiah, size: .large)
                }
            }
            Divider().overlay(Color.hairline)
            KiraProgressRibbon(
                value: Double(debt.paidAmount), target: Double(debt.totalAmount), label: "debt.detail.paid",
                valueLabel: paidLabel)
                .caption(caption)
        }
        .padding(20)
        .kiraCard(cornerRadius: KiraRadius.extraLarge)
        .accessibilityElement(children: .contain)
        .accessibilityLabel(Text("debt.detail.summary \(debt.name)"))
    }

    /** "Rp840.000,00 dari total Rp1.260.000,00". */
    private var caption: LocalizedStringResource {
        "debt.detail.paid.caption \(DebtCopy.rupiah(debt.paidAmount)) \(DebtCopy.rupiah(debt.totalAmount))"
    }

    private var paidLabel: LocalizedStringResource? {
        guard let paid = debt.instalmentsPaid, let total = debt.instalmentsTotal else { return nil }
        return "debt.detail.paid.count \(paid) \(total)"
    }
}

/** Rincian: Cicilan per Bulan, and Jatuh Tempo with the days left. */
struct DebtFacts: View {
    let debt: DebtDetail
    let today: CalendarDay

    var body: some View {
        KiraListGroup("debt.detail.facts") {
            KiraListRow(Text("debt.detail.monthly"), leading: .icon(.wallet))
                .amount(KiraAmount(debt.monthlyInstalment.rupiah))
            if let due = debt.dueDate {
                KiraListRow(Text("debt.detail.due"), leading: .icon(.calendar)) {
                    if let days = debt.daysUntilDue(from: today), days >= 0 {
                        KiraTag("debt.detail.due.days \(days)", tone: .turmeric, icon: .clock)
                    }
                }
                .value(Text(due.date, format: .kiraDate))
            }
        }
    }
}

/** Langkah Berikutnya: the payoff engine's step, its two actions, and "Hanya simulasi". */
struct DebtNextStepSection: View {
    let debt: DebtDetail
    let step: DebtNextStep
    let onOpen: (AppRoute) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let left = debt.instalmentsLeft {
                KiraSectionTitle("debt.detail.next", trailing: .note("debt.detail.next.left \(left)"))
            } else {
                KiraSectionTitle("debt.detail.next")
            }
            card
            Text("debt.detail.next.simulation")
                .font(.caption).foregroundStyle(.inkMuted).padding(.horizontal, KiraSpacing.space1)
        }
        .padding(.top, 6)
    }

    private var card: some View {
        var card = KiraNextStepCard(
            "debt.detail.next.title", message: message, primaryLabel: "debt.detail.next.plan",
            onPrimary: { onOpen(.debtPlan) }, onSecondary: { onOpen(.recordManual) }
        )
        .eyebrow("debt.detail.next.eyebrow").meta("debt.detail.next.meta \(step.priority) \(step.priorityOf)")
        .illustration(.cardPaidOff).secondaryLabel("debt.detail.next.record")
        if let before = step.scoreBefore, let after = step.scoreAfter {
            card = card.impact("debt.detail.next.impact \(before) \(after)")
        }
        return card
    }

    private var message: LocalizedStringResource {
        guard let payOn = step.payOn else {
            return "debt.detail.next.body.undated \(DebtCopy.rupiah(step.extraAmount)) \(debt.name)"
        }
        let day = payOn.date.formatted(.kiraDate)
        return "debt.detail.next.body \(DebtCopy.rupiah(step.extraAmount)) \(day) \(debt.name)"
    }
}

/** Riwayat Pembayaran: each instalment, its day, its amount and whether it was on time. */
struct DebtPaymentHistory: View {
    let debt: DebtDetail

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            KiraSectionTitle("debt.detail.history")
            KiraListGroup {
                ForEach(debt.payments) { payment in
                    KiraListRow(Text("debt.detail.history.number \(payment.number)"), leading: .icon(.receipt)) {
                        if payment.onTime {
                            KiraTag("debt.detail.history.onTime", tone: .healthy, icon: .check)
                        }
                    }
                    .subtitle(Text("debt.detail.history.paidOn \(payment.paidOn.date.formatted(.kiraDate))"))
                    .amount(KiraAmount(payment.amount.rupiah))
                }
            }
            .accessibilityLabel(Text("debt.detail.history.label \(debt.name)"))
        }
        .padding(.top, 6)
    }
}
