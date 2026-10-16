/** The billing operations' outputs, mapped to values or to the problem they carry. */

extension Operations.ListPlans.Output {
    func catalog() throws -> PlanCatalog {
        switch self {
        case .ok(let response):
            let body = try response.body.json
            return PlanCatalog(
                plans: try body.plans.map(PlanTerms.init), current: try bridged(body.current.plan),
                currentPeriod: try bridged(body.current.period))
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .undocumented: throw AppProblem()
        }
    }
}

extension Operations.Checkout.Output {
    func subscription() throws -> Subscription {
        switch self {
        case .ok(let response): return try Subscription(try response.body.json)
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .unprocessableContent(let response): throw try response.body.applicationProblemJson
        case .undocumented: throw AppProblem()
        }
    }
}

extension Operations.GetSubscription.Output {
    func subscription() throws -> Subscription {
        switch self {
        case .ok(let response): return try Subscription(try response.body.json)
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .notFound(let response): throw try response.body.applicationProblemJson
        case .undocumented: throw AppProblem()
        }
    }
}

extension Operations.CancelSubscription.Output {
    func subscription() throws -> Subscription {
        switch self {
        case .ok(let response): return try Subscription(try response.body.json)
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .notFound(let response): throw try response.body.applicationProblemJson
        case .conflict(let response): throw try response.body.applicationProblemJson
        case .undocumented: throw AppProblem()
        }
    }
}

extension Operations.ChangePaymentMethod.Output {
    func subscription() throws -> Subscription {
        switch self {
        case .ok(let response): return try Subscription(try response.body.json)
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .notFound(let response): throw try response.body.applicationProblemJson
        case .unprocessableContent(let response): throw try response.body.applicationProblemJson
        case .undocumented: throw AppProblem()
        }
    }
}

extension Operations.ListInvoices.Output {
    func invoices() throws -> [Invoice] {
        switch self {
        case .ok(let response):
            return try response.body.json.items.map {
                Invoice(
                    id: $0.id, plan: try bridged($0.plan), period: try bridged($0.period), amount: $0.amount,
                    paymentMethod: try bridged($0.paymentMethod), periodStart: $0.periodStart,
                    createdAt: $0.createdAt)
            }
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .undocumented: throw AppProblem()
        }
    }
}

extension Operations.GiftMonths.Output {
    func gift() throws -> Gift {
        switch self {
        case .created(let response):
            let body = try response.body.json
            return Gift(id: body.id, months: body.months, amount: body.amount)
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .unprocessableContent(let response): throw try response.body.applicationProblemJson
        case .undocumented: throw AppProblem()
        }
    }
}
