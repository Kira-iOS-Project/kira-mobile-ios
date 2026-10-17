import Domain
import Features
import SwiftUI

/** Optional link to one of the signed-in person's existing debt accounts. */
struct BillCreateDebtField: View {
    @Bindable var model: BillCreateModel

    var body: some View {
        VStack(alignment: .leading, spacing: KiraSpacing.space3) {
            toggle
            if model.isDebtInstallment { accountChoices }
            if let error = model.debtAccountError {
                Text(error).font(.footnote).foregroundStyle(.vulnerable).padding(.horizontal, 4)
            }
        }
    }

    private var toggle: some View {
        KiraListGroup("bills.create.debt.title") {
            KiraListRow(
                Text("bills.create.debt.toggle"), leading: .icon(.card),
                trailing: .toggle($model.isDebtInstallment))
        }
    }

    @ViewBuilder private var accountChoices: some View {
        if model.isLoadingAccounts {
            ProgressView { Text("bills.create.debt.loading") }
                .frame(maxWidth: .infinity, alignment: .leading)
        } else if let problem = model.debtAccountsProblem {
            VStack(alignment: .leading, spacing: KiraSpacing.space2) {
                KiraNotice(.warning, title: "bills.create.debt.failed", message: problem.message)
                KiraButton("bills.create.retry", variant: .secondary) {
                    Task { await model.retryDebtAccounts() }
                }
            }
        } else if model.debtAccounts.isEmpty {
            KiraNotice(.info, message: "bills.create.debt.empty")
        } else {
            KiraListGroup("bills.create.debt.accounts") {
                ForEach(model.debtAccounts) { account in
                    KiraListRow(
                        Text(account.name), leading: .icon(.wallet),
                        trailing: .check(model.linkedDebtAccountID == account.id),
                        action: { model.linkedDebtAccountID = account.id })
                }
            }
        }
    }
}
