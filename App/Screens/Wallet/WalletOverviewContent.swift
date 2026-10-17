import Domain
import Features
import SwiftUI

struct WalletOverviewContent: View {
    let overview: WalletOverview
    let model: WalletsModel
    let add: () -> Void
    let openDebt: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: KiraSpacing.space4) {
            totals
            KiraNotice(.privacy, message: "wallet.privacy")
            if !overview.wallets.isEmpty { walletGroup }
            if !overview.debts.isEmpty { debtGroup }
            KiraButton("wallet.create.open", action: add).icon(.plus).block()
        }
    }

    private var totals: some View {
        VStack(alignment: .leading, spacing: KiraSpacing.space3) {
            HStack {
                Text("wallet.held.title").font(.footnote.weight(.semibold)).foregroundStyle(.inkMuted)
                Spacer()
                KiraIconButton(
                    model.hidesBalances ? .eye : .eyeOff,
                    label: model.hidesBalances ? "wallet.amount.show" : "wallet.amount.hide"
                ) { model.toggleBalances() }
            }
            KiraAmount(Decimal(overview.heldTotal), size: .large).masked(model.hidesBalances)
            HStack(alignment: .firstTextBaseline) {
                Text("wallet.debt.total").font(.subheadline).foregroundStyle(.inkMuted)
                Spacer(minLength: KiraSpacing.space2)
                KiraAmount(Decimal(overview.runningDebt), size: .small).masked(model.hidesBalances)
            }
        }
        .padding(KiraSpacing.space4)
        .kiraCard(.surfaceRaised)
    }

    private var walletGroup: some View {
        KiraListGroup("wallet.group.held") {
            ForEach(overview.wallets) { wallet in WalletRow(wallet: wallet, model: model).id(wallet.id) }
        }
    }

    private var debtGroup: some View {
        KiraListGroup("wallet.group.debt") {
            ForEach(overview.debts) { wallet in
                WalletRow(wallet: wallet, model: model, openDebt: { openDebt(wallet.id) })
                    .id(wallet.id)
            }
        }
    }
}

private struct WalletRow: View {
    let wallet: Wallet
    let model: WalletsModel
    var openDebt: (() -> Void)?

    var body: some View {
        KiraListRow(Text(wallet.name), leading: .category(wallet.type.category), action: openDebt) {
            HStack(spacing: KiraSpacing.space2) {
                if model.highlightedWalletID == wallet.id {
                    KiraTag("wallet.new", tone: .pandan, icon: .check)
                }
                if model.isDueSoon(wallet) { KiraTag("wallet.dueSoon", tone: .turmeric, icon: .calendar) }
            }
        }
        .subtitle(Text(wallet.type.titleKey))
        .amount(KiraAmount(Decimal(wallet.balance), size: .small).masked(model.hidesBalances))
    }
}
