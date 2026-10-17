import Domain
import SwiftUI

struct DebtDetailContent: View {
    let detail: DebtDetail
    let onPay: () -> Void
    let onOpenSLIK: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: KiraSpacing.space4) {
            balance
            progress
            scoreNotice
            if !detail.nextStep.isEmpty { nextStep }
            schedule
            history
            KiraButton("wallet.payment.open", action: onPay).icon(.plus).block()
            slikGuide
        }
    }

    private var balance: some View {
        HStack(spacing: KiraSpacing.space3) {
            KiraCategoryIcon(detail.account.type.category, size: 52)
            VStack(alignment: .leading, spacing: 3) {
                Text(detail.account.name).font(.headline).foregroundStyle(.ink)
                Text("wallet.debt.remaining").font(.footnote).foregroundStyle(.inkMuted)
                KiraAmount(Decimal(detail.account.balance), size: .large)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(KiraSpacing.space4)
        .kiraCard(.surfaceRaised)
    }

    private var progress: some View {
        KiraProgressRibbon(
            value: Double(detail.paidInstallments), target: Double(detail.totalInstallments),
            label: "wallet.debt.progress",
            valueLabel: "wallet.debt.progress.value \(detail.paidInstallments) \(detail.totalInstallments)"
        )
    }

    private var scoreNotice: some View {
        KiraNotice(
            .simulation, title: "wallet.debt.score.title",
            message: "wallet.debt.score.body \(detail.scoreEstimate.current) \(detail.scoreEstimate.afterPayoff)"
        )
    }

    private var nextStep: some View {
        VStack(alignment: .leading, spacing: KiraSpacing.space2) {
            Text("wallet.debt.nextStep").font(.headline).foregroundStyle(.ink)
            Text(detail.nextStep).font(.body).foregroundStyle(.inkMuted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(KiraSpacing.space4)
        .kiraCard(.surfaceRaised)
    }

    private var schedule: some View {
        KiraListGroup("wallet.debt.schedule") {
            ForEach(detail.schedule) { installment in DebtInstallmentRow(installment: installment) }
        }
    }

    private var history: some View {
        KiraListGroup("wallet.debt.history") {
            ForEach(detail.payments) { payment in DebtPaymentRow(payment: payment) }
        }
    }

    private var slikGuide: some View {
        KiraListGroup("wallet.debt.guide") {
            KiraListRow(Text("wallet.debt.slik"), leading: .icon(.book), action: onOpenSLIK)
                .subtitle(Text("wallet.debt.slik.subtitle"))
        }
    }
}
