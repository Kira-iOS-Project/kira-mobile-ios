import Domain

/** Ringkasan Mingguan as `GET /api/summary/weekly` reports it (UNG-08): numbers only. */
package struct WeeklySummaryDTO: Hashable, Sendable {
    /** One day's spending. */
    package struct Day: Hashable, Sendable {
        /** `YYYY-MM-DD`, WIB. */
        package let date: String
        /** What was spent that day. */
        package let expense: Int
    }

    /** What one category took. */
    package struct Category: Hashable, Sendable {
        /** The category. */
        package let category: TransactionCategory
        /** What was spent on it. */
        package let amount: Int
    }

    /** The first day, `YYYY-MM-DD`. */
    package let start: String
    /** The last day, `YYYY-MM-DD`. */
    package let end: String
    /** Spending this week. */
    package let total: Int
    /** Spending in the seven days before. */
    package let previousTotal: Int
    /** Seven days, oldest first. */
    package let days: [Day]
    /** Every category spent on, largest first. */
    package let categories: [Category]

    init(_ summary: Components.Schemas.WeeklySummary) throws {
        start = summary.start
        end = summary.end
        total = summary.total
        previousTotal = summary.previousTotal
        days = summary.days.map { Day(date: $0.date, expense: $0.expense) }
        categories = try summary.categories.map { Category(category: try bridged($0.category), amount: $0.amount) }
    }
}

extension KiraAPI {
    /** The seven days up to today, WIB (`GET /api/summary/weekly`). */
    package func getWeeklySummary() async throws -> WeeklySummaryDTO {
        try await client.getWeeklySummary().summary()
    }
}

extension Operations.GetWeeklySummary.Output {
    func summary() throws -> WeeklySummaryDTO {
        switch self {
        case .ok(let response): return try WeeklySummaryDTO(try response.body.json)
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .unprocessableContent(let response): throw try response.body.applicationProblemJson
        case .default(_, let response): throw try response.body.applicationProblemJson
        }
    }
}
