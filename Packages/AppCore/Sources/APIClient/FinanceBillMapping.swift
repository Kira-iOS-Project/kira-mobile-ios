import Domain

extension Operations.ListBills.Output {
    /** The bills, or the API's problem (also for a status the route does not list). */
    func billOverview() throws -> BillOverview {
        switch self {
        case .ok(let response):
            let list = try response.body.json
            return BillOverview(
                count: list.count, monthlyTotal: list.monthlyTotal,
                sections: try list.sections.map { section in
                    BillSection(group: billGroup(section.group), bills: try section.bills.compactMap(bill))
                })
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .default(_, let response): throw try response.body.applicationProblemJson
        }
    }
}

/** A section's group as the app names it. */
func billGroup(_ group: Components.Schemas.BillList.SectionsPayloadPayload.GroupPayload) -> BillGroup {
    switch group {
    case .next7Days: .nextSevenDays
    case .thisMonth: .thisMonth
    case .nextMonth: .nextMonth
    case .later: .later
    }
}

/** A listed bill; nil for one with no next due day (a paid one-off, which no group lists). */
func bill(_ row: Components.Schemas.Bill) throws -> Bill? {
    guard let next = row.nextDueOn else { return nil }
    guard let nextDueOn = CalendarDay(iso: next), let dueOn = CalendarDay(iso: row.dueOn) else {
        throw AppProblem()
    }
    return Bill(
        id: row.id, name: row.name, kind: row.kind == .instalment ? .instalment : .bill,
        category: row.category.rawValue, amount: row.amount, isEstimate: row.isEstimate,
        repeats: BillRepeat(rawValue: row.repeats.rawValue) ?? .monthly, dueOn: dueOn, dueDay: row.dueDay,
        nextDueOn: nextDueOn, debtId: row.debtId, remainingInstalments: row.remainingInstalments,
        paidThisPeriod: row.paidThisPeriod)
}
