/**
 One day of Riwayat: "Hari Ini · Kamis 15 Oktober 2026" (or the payday's "· Gajian"), its
 transactions newest first, and the engine's total of the day under it. Each row says category,
 time and source; the amount sits under the title, income signed with "+".
 */
import Domain
import SwiftUI

struct HistoryDayGroup: View {
    let day: HistoryDay
    let period: PayPeriod
    let open: (Domain.Transaction) -> Void

    var body: some View {
        KiraListGroup(title, footer: footer) {
            ForEach(day.transactions) { transaction in
                KiraListRow(Text(transaction.name), leading: .category(transaction.category.tile)) {
                    open(transaction)
                }
                .subtitle(subtitle(transaction))
                .amount(amount(transaction))
            }
        }
    }

    private var title: LocalizedStringResource {
        let date = day.day.date.formatted(.kiraGroupDate)
        switch day.kind {
        case .today: return "history.day.today \(date)"
        case .payday: return "history.day.payday \(date)"
        case .past: return "history.day.past \(date)"
        }
    }

    private var footer: LocalizedStringResource {
        if day.kind == .payday {
            return "history.day.paydayFooter \(DayRange(period).formatted(.kiraDayRange))"
        }
        let isToday = day.kind == .today
        let totals = day.totals
        if totals.expense == 0, totals.income > 0 {
            let income = RupiahFormatStyle().format(Decimal(totals.income))
            return isToday ? "history.day.incomeToday \(income)" : "history.day.incomeThatDay \(income)"
        }
        let expense = RupiahFormatStyle().format(Decimal(totals.expense))
        return isToday ? "history.day.expenseToday \(expense)" : "history.day.expenseThatDay \(expense)"
    }

    private func subtitle(_ transaction: Domain.Transaction) -> Text {
        let time = transaction.occurredAt.formatted(.kiraTime)
        let source = Text(transaction.source.rowLabel)
        if transaction.type == .income {
            return Text("history.row.income \(time) \(source)")
        }
        return Text("history.row.expense \(Text(transaction.category.title)) \(time) \(source)")
    }

    private func amount(_ transaction: Domain.Transaction) -> KiraAmount {
        let amount = KiraAmount(Decimal(transaction.amount), size: .small)
        return transaction.type == .income ? amount.signed() : amount
    }
}
