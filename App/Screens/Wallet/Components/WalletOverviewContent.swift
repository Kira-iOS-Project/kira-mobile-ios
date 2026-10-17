/**
 Dompet's body as the board lays it: the totals card, Uang, Akun Utang with its footer, then the
 privacy notice. Tambah Dompet follows it (WalletsScreen).
 */
import Domain
import Features
import SwiftUI

struct WalletOverviewContent: View {
    let overview: WalletOverview
    let model: WalletsModel
    let openDebt: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: KiraSpacing.space4) {
            WalletTotalsCard(overview: overview, model: model)
            if !overview.wallets.isEmpty { walletGroup }
            if !overview.debts.isEmpty { debtGroup }
            KiraNotice(.privacy, title: "wallet.privacy.title", message: "wallet.privacy")
        }
    }

    private var walletGroup: some View {
        KiraListGroup("wallet.group.held") {
            ForEach(overview.wallets) { wallet in WalletRow(wallet: wallet, model: model).id(wallet.id) }
        }
    }

    private var debtGroup: some View {
        KiraListGroup("wallet.group.debt", footer: "wallet.group.debt.footer") {
            ForEach(overview.debts) { wallet in
                WalletRow(wallet: wallet, model: model, openDebt: { openDebt(wallet.id) })
                    .id(wallet.id)
            }
        }
    }
}

/** "Uang yang kamu pegang" with its count, then the running debt across the debt accounts. */
private struct WalletTotalsCard: View {
    let overview: WalletOverview
    let model: WalletsModel

    var body: some View {
        VStack(alignment: .leading, spacing: KiraSpacing.space3) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: KiraSpacing.space1) {
                    Text("wallet.held.title").font(.footnote.weight(.semibold)).foregroundStyle(.inkMuted)
                    Text("wallet.held.count \(overview.wallets.count)").font(.caption).foregroundStyle(.inkMuted)
                }
                Spacer(minLength: KiraSpacing.space2)
                KiraIconButton(
                    model.hidesBalances ? .eye : .eyeOff,
                    label: model.hidesBalances ? "wallet.amount.show" : "wallet.amount.hide"
                ) { model.toggleBalances() }
            }
            KiraAmount(Decimal(overview.heldTotal), size: .large).masked(model.hidesBalances)
            Rectangle().fill(.hairline).frame(height: 1).accessibilityHidden(true)
            HStack(alignment: .center, spacing: KiraSpacing.space3) {
                KiraIcon(.card, size: 18).foregroundStyle(.inkMuted).accessibilityHidden(true)
                Text("wallet.debt.total \(overview.debts.count)").font(.subheadline).foregroundStyle(.inkMuted)
                Spacer(minLength: KiraSpacing.space2)
                KiraAmount(Decimal(overview.runningDebt), size: .small).masked(model.hidesBalances)
            }
        }
        .padding(KiraSpacing.space4)
        .kiraCard(.surfaceRaised)
    }
}

private struct WalletRow: View {
    let wallet: Wallet
    let model: WalletsModel
    var openDebt: (() -> Void)?

    var body: some View {
        KiraListRow(Text(wallet.name), leading: .category(wallet.type.category), action: openDebt) {
            if let due = wallet.nextDueAt {
                KiraTag(
                    "wallet.dueOn \(due.formatted(.kiraDate))", tone: model.isDueSoon(wallet) ? .turmeric : .neutral,
                    icon: .clock)
            }
        }
        .subtitle(Text(wallet.type.isDebt ? "wallet.debt.remaining" : wallet.type.titleKey))
        .amount(KiraAmount(Decimal(wallet.balance), size: .small).masked(model.hidesBalances))
    }
}
