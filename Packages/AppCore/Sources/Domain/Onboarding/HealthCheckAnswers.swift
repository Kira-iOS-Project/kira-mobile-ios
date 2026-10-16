/**
 Every answer of the six-step health check, as `PUT /health-check` takes it. A skipped amount is
 nil; the server stores what it gets and the score engine reads a missing amount as its rules say.
 */
package struct HealthCheckAnswers: Hashable, Sendable {
    /** Step 1: net income per month. */
    package var netMonthlyIncome: Int?
    /** Step 1: the day pay arrives. */
    package var payday: Payday
    /** Step 2: essential spending per month. */
    package var essentialMonthlyExpenses: Int?
    /** Step 3: the debts, empty for none. */
    package var debts: [DebtEntry]
    /** Step 4: money ready to use at any time. */
    package var emergencyFund: Int?
    /** Step 4: what is put aside each month. */
    package var monthlySavings: Int?
    /** Step 5: gold, shares, funds or deposits. */
    package var otherAssets: Int?
    /** Step 5: vehicles and property. */
    package var propertyAssets: Int?
    /** Step 6: people who depend on the person, 0 to 3 (3 means three or more). */
    package var dependents: Int
    /** Step 6: marital status, nil when not answered. */
    package var maritalStatus: MaritalStatus?
    /** Step 6: the protections held, empty for none. */
    package var protections: Set<Protection>

    /** Answers with nothing filled in yet: pay on the 25th, no debts, no dependents. */
    package init() {
        payday = Payday(day: Payday.defaultDay)
        debts = []
        dependents = 0
        protections = []
    }
}
