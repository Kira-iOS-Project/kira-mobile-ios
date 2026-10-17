/** The phrases of Rencana Pelunasan that depend on the plan's numbers. */
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

    /** What the chosen method does to the interest. */
    static func interest(_ outcome: PayoffComparison.InterestOutcome) -> LocalizedStringResource {
        switch outcome {
        case .saves(let amount): "payoff.compare.saves \(rupiah(amount))"
        case .costs(let amount): "payoff.compare.costs \(rupiah(amount))"
        case .same: "payoff.compare.same"
        case .unknown: "payoff.compare.unknown"
        }
    }

    /** What the chosen method does to the first payoff; nil when the API did not say. */
    static func firstPayoff(_ outcome: PayoffComparison.FirstPayoffOutcome) -> LocalizedStringResource? {
        switch outcome {
        case .sooner(let months): "payoff.compare.first.sooner \(months)"
        case .later(let months): "payoff.compare.first.later \(months)"
        case .same: "payoff.compare.first.same"
        case .unknown: nil
        }
    }
}
