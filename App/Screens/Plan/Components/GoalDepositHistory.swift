import Domain
import SwiftUI

/** Riwayat Setoran: each deposit by its month, newest first. */
struct GoalDepositHistory: View {
    let deposits: [GoalDeposit]

    var body: some View {
        if !deposits.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                KiraSectionTitle("plan.detail.history")
                KiraListGroup("plan.detail.history.label") {
                    ForEach(deposits, id: \.id) { deposit in
                        KiraListRow(
                            Text("plan.detail.history.row \(deposit.depositedOn.date, format: .kiraMonth)"),
                            leading: .category(.savings), trailing: .none
                        )
                        .subtitle(Text(deposit.depositedOn.date, format: .kiraDate))
                        .amount(KiraAmount(Decimal(deposit.amount), size: .small))
                    }
                }
            }
            .padding(.top, 6)
        }
    }
}
