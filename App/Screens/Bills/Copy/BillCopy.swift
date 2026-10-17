/**
 The words Tagihan & Cicilan gives its values (board Tagihan): the group titles and footer, each
 row's schedule, the category's icon, and the dates and months in the tags.
 */
import Domain
import Foundation
import SwiftUI

extension BillGroup {
    /** "7 Hari ke Depan", "Bulan Ini", "Bulan Depan"; a yearly bill further on under "Nanti". */
    var title: LocalizedStringResource {
        switch self {
        case .nextSevenDays: "bills.group.nextSevenDays"
        case .thisMonth: "bills.group.thisMonth"
        case .nextMonth: "bills.group.nextMonth"
        case .later: "bills.group.later"
        }
    }
}

extension BillOverview {
    /** The group whose footer says instalments are linked to their debt account: the first holding one. */
    var instalmentNoteGroup: BillGroup? {
        sections.first { section in section.bills.contains { $0.kind == .instalment } }?.group
    }
}

extension Bill {
    /** "Tiap Tanggal 20", "Cicilan Tiap Tanggal 28 · 14 Bulan Lagi". */
    var schedule: LocalizedStringResource {
        switch (kind, remainingInstalments) {
        case (.instalment, let months?): "bills.schedule.instalment.left \(dueDay) \(months)"
        case (.instalment, nil): "bills.schedule.instalment \(dueDay)"
        case (.bill, _): "bills.schedule.bill \(dueDay)"
        }
    }

    /** The row's category icon, from the ledger's category key. */
    var kiraCategory: KiraCategory {
        switch category {
        case "bills": .bills
        case "household": .home
        case "transport": .transport
        case "insurance": .protection
        case "paylater_instalment": .paylater
        case "entertainment": .entertainment
        case "health": .health
        case "education": .education
        default: .other
        }
    }
}

/** Dates and months in Indonesian, in WIB. */
enum BillCopy {
    /** "5 November 2026". */
    static func date(_ day: CalendarDay) -> String { day.date.formatted(.kiraDate) }

    /** "Oktober" for 10. */
    static func month(_ month: Int) -> String {
        CalendarDay(year: 2026, month: month, day: 1).date.formatted(.kiraMonth)
    }
}
