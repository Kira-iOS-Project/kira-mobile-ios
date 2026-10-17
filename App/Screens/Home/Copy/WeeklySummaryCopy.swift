/**
 The sentences of Ringkasan Mingguan, written on the device from the week's numbers (board
 RingkasanMingguan): the hand note, the comparison with the week before, the busiest and quietest
 days, each category's share, and the Catatan Minggu Ini note.
 */
import Domain
import SwiftUI

extension WeeklySummary {
    private var reading: WeeklySummaryReading { WeeklySummaryReading(self) }

    /** "8–14 Oktober 2026". */
    var rangeText: String { DayRange(first: start, last: end).formatted(.kiraDayRange) }

    /** "Kamis 8 Oktober – Rabu 14 Oktober 2026". */
    var daysText: LocalizedStringResource {
        "summary.weekly.days \(start.date.formatted(.kiraWeekdayDayMonth)) \(end.date.formatted(.kiraGroupDate))"
    }

    /** Kuku's hand note: "minggu ini sedikit lebih hemat". */
    var handNote: LocalizedStringResource {
        switch reading.comparison {
        case .less: "summary.weekly.note.less"
        case .more: "summary.weekly.note.more"
        case .same: "summary.weekly.note.same"
        }
    }

    /** "Rp120.000,00 Lebih Sedikit dari Minggu Lalu", and whether it is good news. */
    var comparisonTag: (text: LocalizedStringResource, isLess: Bool) {
        switch reading.comparison {
        case .less(let amount): ("summary.weekly.less \(Decimal(amount).formatted(.rupiah))", true)
        case .more(let amount): ("summary.weekly.more \(Decimal(amount).formatted(.rupiah))", false)
        case .same: ("summary.weekly.same", false)
        }
    }

    /** One bar per day, the busiest highlighted. */
    var columns: [KiraBars.Column] {
        let busiest = reading.busiest?.day
        return days.map { day in
            KiraBars.Column(
                label: "summary.weekly.weekday \(day.day.date.formatted(.kiraWeekday))", value: Double(day.amount),
                isHighlighted: day.day == busiest)
        }
    }

    /** The bars for VoiceOver: "Pengeluaran per hari, 8 sampai 14 Oktober. Paling besar Sabtu, Rp310.000,00". */
    var chartLabel: LocalizedStringResource {
        let span = DayRange(first: start, last: end)
        guard let busiest = reading.busiest else {
            return "summary.weekly.chart.empty \(span.firstEnd) \(span.lastEnd)"
        }
        let amount = Decimal(busiest.amount).formatted(.rupiah)
        return "summary.weekly.chart \(span.firstEnd) \(span.lastEnd) \(weekday(busiest)) \(amount)"
    }

    /** "Paling besar **Sabtu, Rp310.000,00**. Paling kecil Senin, Rp95.000,00." */
    var extremesText: Text? {
        guard let busiest = reading.busiest, let quietest = reading.quietest else { return nil }
        let most = Text(
            "summary.weekly.busiestDay \(weekday(busiest)) \(Text(Decimal(busiest.amount), format: .rupiah))"
        )
        .fontWeight(.semibold)
        let least = Text(Decimal(quietest.amount), format: .rupiah)
        return Text("summary.weekly.extremes \(most) \(weekday(quietest)) \(least)")
    }

    /** "Terbesar Minggu Ini": the four largest categories with their shares. */
    var topShares: [WeeklySummaryReading.Share] { reading.top }

    /**
     Catatan Minggu Ini: where the week went, from its days and categories. A weekend that took the
     most, mostly on food, gets the board's suggestion to cook one weekend day.
     */
    var note: LocalizedStringResource? {
        guard let top = reading.top.first?.spending.category else { return nil }
        let name = String(localized: top.title)
        switch (reading.isWeekendHeavy, top) {
        case (true, .food): return "summary.weekly.tip.weekendFood"
        case (true, _): return "summary.weekly.tip.weekend \(name)"
        case (false, _): return "summary.weekly.tip.top \(name)"
        }
    }

    private func weekday(_ day: DaySpending) -> String { day.day.date.formatted(.kiraWeekday) }
}
