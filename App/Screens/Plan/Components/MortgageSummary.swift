/**
 Simulasi KPR on Hasil Simulasi · DP Rumah (board HasilTujuanDP): the instalment's health as a tag
 and its sentence, the loan's five figures, and Biaya Lain Saat Beli with its total and footer.
 */
import Domain
import SwiftUI

struct MortgageSummary: View {
    let mortgage: Mortgage

    var body: some View {
        KiraSectionTitle("plan.kpr.title").padding(.top, KiraSpacing.space2)
        VStack(alignment: .leading, spacing: 6) {
            KiraTag(mortgage.health.tag, tone: mortgage.health.tone, icon: .shield)
            Text("plan.kpr.health.body \(highestShare) \(mortgage.health.limit)")
                .font(.subheadline).kiraLineHeight(21, size: 15).foregroundStyle(.ink)
        }
        .padding(KiraSpacing.space4)
        .frame(maxWidth: .infinity, alignment: .leading)
        .kiraCard()
        .accessibilityElement(children: .combine)
        loan
        costs
    }

    private var loan: some View {
        let months = mortgage.tenorYears * 12
        let fixMonths = mortgage.fixYears * 12
        return KiraListGroup {
            KiraListRow(Text("plan.kpr.loan"), leading: .icon(.receipt))
                .subtitle(Text("plan.kpr.loan.detail \(mortgage.tenorYears) \(months)"))
                .amount(KiraAmount(mortgage.loan.rupiah))
            KiraListRow(Text("plan.kpr.fixInstalment"), leading: .icon(.calendar))
                .subtitle(Text("plan.kpr.fixInstalment.detail \(fixMonths) \(GoalCopy.percent(mortgage.fixRate))"))
                .amount(KiraAmount(mortgage.fixInstalment.rupiah))
            KiraListRow(Text("plan.kpr.floatInstalment"), leading: .icon(.calendar))
                .subtitle(Text("plan.kpr.floatInstalment.detail \(months - fixMonths) \(floatRate)"))
                .amount(KiraAmount(mortgage.floatInstalment.rupiah))
            KiraListRow(Text("plan.kpr.interest"), leading: .icon(.chart))
                .subtitle(Text("plan.kpr.interest.detail \(Text(mortgage.interestShare * 100, format: .kiraMultiple))"))
                .amount(KiraAmount(mortgage.totalInterest.rupiah))
            KiraListRow(Text("plan.kpr.remaining"), leading: .icon(.wallet))
                .amount(KiraAmount(mortgage.remainingAfterFix.rupiah))
        }
        .accessibilityLabel(Text("plan.kpr.analysis"))
    }

    private var costs: some View {
        let costs = mortgage.costs
        return KiraListGroup("plan.kpr.costs", footer: "plan.kpr.costs.footer") {
            row("plan.kpr.bphtb", "plan.kpr.bphtb.detail", costs.bphtb)
            row("plan.kpr.deed", "plan.kpr.ofPrice \(1)", costs.deed)
            row("plan.kpr.transfer", "plan.kpr.ofPrice \(1)", costs.transfer)
            row("plan.kpr.notary", "plan.kpr.ofPrice.decimal \(notaryText)", costs.notary)
            row("plan.kpr.provision", "plan.kpr.ofLoan", costs.provision)
            row("plan.kpr.appraisal", nil, costs.appraisal)
            row("plan.kpr.admin", nil, costs.admin)
            row("plan.kpr.costs.total", nil, costs.total)
        }
    }

    /** "29,9" for the instalment's share of the income. */
    private var highestShare: Text { Text(mortgage.highestShare * 100, format: .kiraDecimal(1)) }

    private var floatRate: Text { GoalCopy.percent(mortgage.floatRate) }

    private var notaryText: Text { Text(notaryPercent, format: .kiraMultiple) }

    /** 2,5% under Rp100.000.000,00, 1% above Rp1.000.000.000,00, else 1,5% (the site's rule). */
    private var notaryPercent: Double {
        mortgage.price < 100_000_000 ? 2.5 : mortgage.price > 1_000_000_000 ? 1 : 1.5
    }

    private func row(_ title: LocalizedStringResource, _ detail: LocalizedStringResource?, _ amount: Int) -> some View {
        var row = KiraListRow(Text(title)).amount(KiraAmount(amount.rupiah))
        if let detail { row = row.subtitle(Text(detail)) }
        return row
    }
}

extension MortgageHealth {
    /** "Cicilan Sangat Sehat" … "Cicilan Berbahaya". */
    var tag: LocalizedStringResource {
        switch self {
        case .veryHealthy: "plan.kpr.health.veryHealthy"
        case .healthy: "plan.kpr.health.healthy"
        case .unhealthy: "plan.kpr.health.unhealthy"
        case .dangerous: "plan.kpr.health.dangerous"
        }
    }

    var tone: KiraTag.Tone {
        switch self {
        case .veryHealthy, .healthy: .healthy
        case .unhealthy: .turmeric
        case .dangerous: .vulnerable
        }
    }

    /** The band's upper edge in the sentence ("Batas sehat sampai 30%"). */
    var limit: LocalizedStringResource {
        switch self {
        case .veryHealthy: "plan.kpr.limit.veryHealthy"
        case .healthy: "plan.kpr.limit.healthy"
        case .unhealthy: "plan.kpr.limit.unhealthy"
        case .dangerous: "plan.kpr.limit.dangerous"
        }
    }
}
