/**
 The parts of Rencanaku (board PelunasanAktif): the hero for the account being paid off, the
 payment to make next with its Cicilan and Tambahan, every account in the plan's order, and the
 card that says every consumer account is paid.
 */
import Domain
import Features
import SwiftUI

/** "Akun 1 dari 3", "Paylater A lunas dalam 10 hari" and what is paid of it, on the hero. */
struct PayoffPlanHero: View {
    let plan: ActivePayoffPlan
    let account: PlanAccount

    var body: some View {
        VStack(alignment: .leading, spacing: KiraSpacing.space2) {
            HStack(spacing: KiraSpacing.space3) {
                if let position = plan.position(of: account.id) {
                    Text("plan.hero.position \(position) \(plan.accounts.count)")
                        .kiraFont(.overline).kiraSmallType().foregroundStyle(.onHeroMuted)
                }
                Spacer(minLength: 0)
                KiraHandNote("plan.hero.note", tone: .hero, size: .small, tilt: -3)
                    .accessibilityHidden(true)
            }
            .frame(minHeight: 24)
            Text(PayoffPlanCopy.headline(account, countdown: plan.focusCountdown))
                .font(KiraFont.display(26, axisWeight: 750, relativeTo: .title1, typeSize: typeSize))
                .kiraLineHeight(32, size: 26, relativeTo: .title)
                .tracking(-0.52)
                .foregroundStyle(.onHero)
                .accessibilityAddTraits(.isHeader)
                .balancedLines()
            KiraProgressRibbon(
                value: Double(account.paid), target: Double(account.original), label: "plan.hero.paid",
                valueLabel: "plan.hero.percent \(account.progressPercent)"
            )
            .caption(PayoffPlanCopy.paidCaption(account))
            .inverse()
            .padding(.top, 10)
        }
        .padding(KiraSpacing.space5)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(alignment: .bottom) { KiraScenery(tone: .hero, height: 92).accessibilityHidden(true) }
        .background(.hero)
        .clipShape(RoundedRectangle(cornerRadius: KiraRadius.extraLarge, style: .continuous))
        .accessibilityElement(children: .contain)
        .accessibilityLabel(Text("plan.hero.label"))
    }

    @Environment(\.dynamicTypeSize) private var typeSize
}

/** Pembayaran Berikutnya: when, how much, its Cicilan and Tambahan, and Tandai Sudah Bayar. */
struct PayoffNextPaymentCard: View {
    let payment: NextPayment
    let category: KiraCategory
    let isWorking: Bool
    let onPaid: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: KiraSpacing.space3) {
                Text("plan.next.title").font(.body.weight(.semibold)).kiraLineHeight(22, size: 17)
                    .foregroundStyle(.ink).accessibilityAddTraits(.isHeader)
                Spacer(minLength: 0)
                if let left = PayoffPlanCopy.daysLeft(payment) {
                    KiraTag(left, tone: .turmeric, icon: .clock)
                }
            }
            HStack(spacing: KiraSpacing.space3) {
                KiraCategoryIcon(category, size: 56)
                VStack(alignment: .leading, spacing: 2) {
                    Text(PayoffPlanCopy.payee(payment))
                        .font(.footnote.weight(.semibold)).kiraLineHeight(18, size: 13).foregroundStyle(.inkMuted)
                    KiraAmount(Decimal(payment.amount), size: .large)
                }
            }
            .accessibilityElement(children: .combine)
            VStack(alignment: .leading, spacing: 6) {
                PaymentPart(label: "plan.next.instalment", amount: payment.instalment)
                if payment.extra > 0 {
                    PaymentPart(label: "plan.next.extra", amount: payment.extra)
                }
            }
            .padding(EdgeInsets(top: 12, leading: 14, bottom: 12, trailing: 14))
            .frame(maxWidth: .infinity, alignment: .leading)
            .kiraCard(.surface, cornerRadius: KiraRadius.small)
            KiraButton("plan.pay", action: onPaid).icon(.check).block()
                .disabled(isWorking)
        }
        .padding(KiraSpacing.space5)
        .frame(maxWidth: .infinity, alignment: .leading)
        .kiraCard()
    }
}

/** "Cicilan Rp210.000,00": one part of the payment. */
private struct PaymentPart: View {
    let label: LocalizedStringResource
    let amount: Int

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: KiraSpacing.space2) {
            Text(label).foregroundStyle(.inkMuted).frame(minWidth: 76, alignment: .leading)
            Text(PayoffCopy.rupiah(amount)).fontWeight(.semibold).monospacedDigit().foregroundStyle(.ink)
        }
        .font(.subheadline).kiraLineHeight(20, size: 15)
        .accessibilityElement(children: .combine)
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
        .padding(KiraSpacing.space5)
        .frame(maxWidth: .infinity, alignment: .leading)
        .kiraCard()
    }
}

/**
 Semua Akun: every account in the plan's order (those already paid first) with what is left, when
 it is paid off, and its tag.
 */
struct PayoffPlanAccounts: View {
    let plan: ActivePayoffPlan
    /** Opens an account's detail. */
    let onOpen: (PlanAccount) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            KiraSectionTitle("plan.accounts.title")
            VStack(spacing: KiraSpacing.space2) {
                ForEach(Array(plan.accounts.enumerated()), id: \.element.id) { index, account in
                    PayoffAccountTile(
                        rank: index + 1, category: account.kind.category, name: account.name,
                        lines: lines(account), tag: PayoffPlanCopy.tag(account),
                        tagTone: tone(account.status)
                    ) { onOpen(account) }
                }
            }
        }
        .padding(.top, KiraSpacing.space1)
    }

    /** Sedang Dilunasi in pandan, Lunas in healthy green, the rest neutral. */
    private func tone(_ status: PlanAccountStatus) -> KiraTag.Tone {
        switch status {
        case .inProgress: .pandan
        case .paidOff: .healthy
        case .next, .ongoing: .neutral
        }
    }

    /** What is left and when it is paid off; a paid account says only when it was paid. */
    private func lines(_ account: PlanAccount) -> [LocalizedStringResource] {
        let payoff = PayoffPlanCopy.payoff(account)
        if account.status == .paidOff { return payoff.map { [$0] } ?? [] }
        let remaining: LocalizedStringResource = "plan.account.remaining \(PayoffCopy.rupiah(account.remaining))"
        guard let payoff else { return [remaining] }
        return [remaining, payoff]
    }
}
