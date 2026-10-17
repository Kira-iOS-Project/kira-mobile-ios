/** The phrases of Rencana Pelunasan that depend on the plan's numbers and the method. */
import Domain
import Foundation

enum PayoffCopy {
    /** "November 2026" for the `YYYY-MM` the API sends; nil when there is none or it cannot be read. */
    static func month(_ iso: String?) -> String? {
        guard let iso, let day = CalendarDay(iso: "\(iso)-01") else { return nil }
        return day.date.formatted(.kiraMonthYear)
    }

    /** `amount` in whole rupiah, as the screen writes it. */
    static func rupiah(_ amount: Int) -> String {
        RupiahFormatStyle().format(Decimal(amount))
    }

    /** "25 Oktober 2026" on its due day, "Oktober 2026" without one; nil when it is never paid off. */
    static func date(of account: PayoffAccount) -> String? {
        account.payoffDay?.date.formatted(.kiraDate) ?? month(account.payoffMonth)
    }

    /** "Lunas 25 Oktober 2026", or "Belum lunas dalam 50 tahun". */
    static func when(_ account: PayoffAccount) -> LocalizedStringResource {
        date(of: account).map { "payoff.row.when \($0)" } ?? "payoff.account.never"
    }

    /** The hero's day for the first account, or that it is never paid off. */
    static func heroDate(_ account: PayoffAccount) -> LocalizedStringResource {
        date(of: account).map { "payoff.hero.date \($0)" } ?? "payoff.account.never"
    }

    /** "Semua utang konsumtif lunas 5 Januari 2027", or that the plan does not get there. */
    static func allPaid(_ simulation: PayoffSimulation) -> LocalizedStringResource {
        let day = simulation.allPaidDay?.date.formatted(.kiraDate) ?? month(simulation.allPaidMonth)
        return day.map { "payoff.hero.allPaid \($0)" } ?? "payoff.hero.notAll"
    }

    /**
     The two lines of the formula box: Snowball adds the extra to the first account's instalment and
     names the sum ("= Rp420.000,00 → Paylater A lunas"); Avalanche gives the sum per month and the
     first account's day.
     */
    static func formula(_ simulation: PayoffSimulation, first: PayoffAccount) -> [LocalizedStringResource] {
        let extra = rupiah(simulation.extraPayment)
        let instalment = rupiah(first.monthlyInstalment)
        switch simulation.method {
        case .snowball:
            let total = rupiah(simulation.extraPayment + first.monthlyInstalment)
            return [
                "payoff.how.sumSnowball \(extra) \(instalment)", "payoff.how.resultSnowball \(total) \(first.name)",
            ]
        case .avalanche:
            return [
                "payoff.how.sum \(extra) \(instalment)", "payoff.how.result \(first.name) \(date(of: first) ?? "")",
            ]
        }
    }

    /** The method's line under the segmented control. */
    static func methodLine(_ method: PayoffMethod) -> LocalizedStringResource {
        switch method {
        case .snowball: "payoff.method.snowballLine"
        case .avalanche: "payoff.method.avalancheLine"
        }
    }

    /** Where the extra goes, in "Gimana Ngitungnya?". */
    static func howRule(_ method: PayoffMethod) -> LocalizedStringResource {
        switch method {
        case .snowball: "payoff.how.snowball"
        case .avalanche: "payoff.how.avalanche"
        }
    }

    /** "yang kecil dulu" or "bunga tertinggi dulu" beside "Urutan Pelunasan". */
    static func orderNote(_ method: PayoffMethod) -> LocalizedStringResource {
        switch method {
        case .snowball: "payoff.order.snowball"
        case .avalanche: "payoff.order.avalanche"
        }
    }

    /** "Fokus Bulan Ini" for the first, "Mulai November" after it, or "Mulai Setelah Paylater B". */
    static func tag(_ account: PayoffAccount, in simulation: PayoffSimulation) -> LocalizedStringResource {
        if account.position == 1 { return "payoff.tag.first" }
        if let start = simulation.startMonth(of: account) {
            return "payoff.tag.start \(start.date.formatted(.kiraMonth))"
        }
        return "payoff.tag.after \(simulation.previous(of: account)?.name ?? "")"
    }

    /** "Kalau Pakai Avalanche" on Snowball, "Dibanding Snowball" on Avalanche. */
    static func comparisonTitle(_ chosen: PayoffMethod) -> LocalizedStringResource {
        switch chosen {
        case .snowball: "payoff.compare.ifAvalanche"
        case .avalanche: "payoff.compare.againstSnowball"
        }
    }

    /** Avalanche against Snowball, whichever is chosen: the interest, then the first payoff. */
    static func comparison(_ comparison: PayoffComparison, chosen: PayoffMethod) -> LocalizedStringResource {
        let flip = chosen == .avalanche ? 1 : -1
        guard let saved = comparison.interestSaved.map({ $0 * flip }) else { return "payoff.compare.unknown" }
        let interest =
            saved > 0
            ? String(localized: "payoff.compare.cheaper \(rupiah(saved))")
            : saved < 0
                ? String(localized: "payoff.compare.dearer \(rupiah(-saved))")
                : String(localized: "payoff.compare.sameInterest")
        guard let later = comparison.firstPayoffMonthsLater.map({ $0 * -flip }) else {
            return "payoff.compare.only \(interest)"
        }
        let first =
            later > 0
            ? String(localized: "payoff.compare.later \(later)")
            : later < 0
                ? String(localized: "payoff.compare.sooner \(-later)") : String(localized: "payoff.compare.sameMonth")
        return (saved > 0) == (later > 0) && saved != 0 && later != 0
            ? "payoff.compare.but \(interest) \(first)" : "payoff.compare.and \(interest) \(first)"
    }
}
