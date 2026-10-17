import Domain

/** The server-calculated Thursday-to-Wednesday summary. */
extension KiraAPI {
    /** `GET /api/summaries/weekly?week=`; `weekStart` is a Thursday. */
    package func getWeeklySummary(weekStart: CalendarDay) async throws -> WeeklySummary {
        try await client.getWeeklySummary(query: .init(week: weekStart.iso)).weeklySummary()
    }
}

extension Operations.GetWeeklySummary.Output {
    func weeklySummary() throws -> WeeklySummary {
        switch self {
        case .ok(let response): try mapWeeklySummary(response.body.json)
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .unprocessableContent(let response): throw try response.body.applicationProblemJson
        case .default: throw AppProblem()
        }
    }
}

private func mapWeeklySummary(_ row: Components.Schemas.WeeklySummary) throws -> WeeklySummary {
    guard let weekStart = CalendarDay(iso: row.period.from) else { throw AppProblem() }
    let days = try row.days.map {
        guard let date = CalendarDay(iso: $0.date) else { throw AppProblem() }
        return WeeklySummaryDay(date: date, expense: $0.expense, income: $0.income)
    }
    let categories = try row.topCategories.map {
        let category = try bridged($0.category) as TransactionCategory
        return WeeklyTopCategory(category: category.rawValue, name: category.rawValue, amount: $0.amount)
    }
    return WeeklySummary(
        weekStart: weekStart,
        totals: WeeklyTotals(expense: row.totals.expense, income: row.totals.income, net: row.totals.net),
        previousTotals: WeeklyTotals(expense: row.previous.expense, income: row.previous.income, net: row.previous.net),
        days: days, topCategories: categories, note: row.note)
}
