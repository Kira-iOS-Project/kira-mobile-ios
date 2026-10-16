/**
 How Catat writes dates, times and categories. Kira's times are WIB and its dates are written in
 full in Indonesian whatever the phone's region ("15 Oktober 2026 · 12.41 WIB"), as product rules.
 */
import Domain
import SwiftUI

nonisolated enum RecordFormat {
    private static let jakarta = TimeZone(identifier: "Asia/Jakarta") ?? .current
    private static let indonesian = Locale(identifier: "id_ID")

    /** "15 Oktober 2026". */
    static let day = Date.FormatStyle(date: .long, time: .omitted, locale: indonesian, timeZone: jakarta)
    /** "Kamis, 15 Oktober 2026". */
    static let weekday = Date.FormatStyle(locale: indonesian, timeZone: jakarta).weekday(.wide).day().month(.wide)
        .year()
    /** "25 September", the start of a period. */
    static let dayMonth = Date.FormatStyle(locale: indonesian, timeZone: jakarta).day().month(.wide)
    /** "Oktober". */
    static let month = Date.FormatStyle(locale: indonesian, timeZone: jakarta).month(.wide)
    /** "12.41", followed by "WIB" in the catalog's sentences. */
    static let time = Date.FormatStyle(locale: indonesian, timeZone: jakarta).hour(.twoDigits(amPM: .omitted))
        .minute(.twoDigits)
}

nonisolated extension TransactionCategory {
    /** The design system's tile for the category, as the boards draw it (Bonus on the savings tile). */
    var tile: KiraCategory {
        switch self {
        case .food: .food
        case .coffee: .coffee
        case .transport: .transport
        case .shopping, .business: .shopping
        case .bills: .bills
        case .paylaterInstalment: .paylater
        case .savingsDeposit, .bonus: .savings
        case .insurance: .protection
        case .entertainment: .entertainment
        case .health: .health
        case .education: .education
        case .household: .home
        case .otherExpense, .otherIncome: .other
        case .salary: .salary
        }
    }

    /** The category's name in Catat ("Makan & Minum"). */
    var title: LocalizedStringResource {
        switch self {
        case .food: "record.category.food"
        case .coffee: "record.category.coffee"
        case .transport: "record.category.transport"
        case .shopping: "record.category.shopping"
        case .bills: "record.category.bills"
        case .paylaterInstalment: "record.category.paylater"
        case .savingsDeposit: "record.category.savings"
        case .insurance: "record.category.insurance"
        case .entertainment: "record.category.entertainment"
        case .health: "record.category.health"
        case .education: "record.category.education"
        case .household: "record.category.household"
        case .otherExpense, .otherIncome: "record.category.other"
        case .salary: "record.category.salary"
        case .bonus: "record.category.bonus"
        case .business: "record.category.business"
        }
    }
}

/** A count in words, "Tiga", for "Tiga transaksi tersimpan."; above ten in digits. */
func countWord(_ count: Int) -> Text {
    switch count {
    case 2: Text("record.count.two")
    case 3: Text("record.count.three")
    case 4: Text("record.count.four")
    case 5: Text("record.count.five")
    case 6: Text("record.count.six")
    case 7: Text("record.count.seven")
    case 8: Text("record.count.eight")
    case 9: Text("record.count.nine")
    case 10: Text("record.count.ten")
    default: Text(count, format: .number)
    }
}
