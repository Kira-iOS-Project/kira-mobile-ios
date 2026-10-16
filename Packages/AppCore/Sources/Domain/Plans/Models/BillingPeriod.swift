/** How often a plan is paid: the backend's `BILLING_PERIOD` values. */
package enum BillingPeriod: String, CaseIterable, Codable, Sendable {
    /** Paid every month. */
    case monthly
    /** Paid once a year, ten months' price for twelve. */
    case yearly

    /** The day a subscription bought on `day` renews: a month or a year on. */
    package func renewal(after day: CalendarDay) -> CalendarDay {
        switch self {
        case .monthly: day.adding(months: 1)
        case .yearly: day.adding(years: 1)
        }
    }
}
