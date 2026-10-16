/** The billing operations' outputs, mapped to values or to the problem they carry. */

extension Operations.ListPlans.Output {
    func catalog() throws -> PlanCatalogDTO {
        switch self {
        case .ok(let response):
            let body = try response.body.json
            return PlanCatalogDTO(
                plans: try body.plans.map(PlanTermsDTO.init), current: try bridged(body.current.plan))
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .default(_, let response): throw try response.body.applicationProblemJson
        }
    }
}

extension Operations.Checkout.Output {
    func subscription() throws -> SubscriptionDTO {
        switch self {
        case .ok(let response): return try SubscriptionDTO(try response.body.json)
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .unprocessableContent(let response): throw try response.body.applicationProblemJson
        case .default(_, let response): throw try response.body.applicationProblemJson
        }
    }
}

extension Operations.GetSubscription.Output {
    func subscription() throws -> SubscriptionDTO {
        switch self {
        case .ok(let response): return try SubscriptionDTO(try response.body.json)
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .notFound(let response): throw try response.body.applicationProblemJson
        case .default(_, let response): throw try response.body.applicationProblemJson
        }
    }
}

extension Operations.CancelSubscription.Output {
    func subscription() throws -> SubscriptionDTO {
        switch self {
        case .ok(let response): return try SubscriptionDTO(try response.body.json)
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .notFound(let response): throw try response.body.applicationProblemJson
        case .conflict(let response): throw try response.body.applicationProblemJson
        case .default(_, let response): throw try response.body.applicationProblemJson
        }
    }
}

extension Operations.ChangePaymentMethod.Output {
    func subscription() throws -> SubscriptionDTO {
        switch self {
        case .ok(let response): return try SubscriptionDTO(try response.body.json)
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .notFound(let response): throw try response.body.applicationProblemJson
        case .unprocessableContent(let response): throw try response.body.applicationProblemJson
        case .default(_, let response): throw try response.body.applicationProblemJson
        }
    }
}

extension Operations.ListInvoices.Output {
    func invoices() throws -> [InvoiceDTO] {
        switch self {
        case .ok(let response):
            return try response.body.json.items.map {
                InvoiceDTO(
                    id: $0.id, plan: try bridged($0.plan), amount: $0.amount,
                    paymentMethod: try bridged($0.paymentMethod), periodStart: $0.periodStart)
            }
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .default(_, let response): throw try response.body.applicationProblemJson
        }
    }
}

extension Operations.GiftMonths.Output {
    /** Nothing a screen reads comes back: the thank-you dialog only needs the gift to be accepted. */
    func confirm() throws {
        switch self {
        case .created: return
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .unprocessableContent(let response): throw try response.body.applicationProblemJson
        case .default(_, let response): throw try response.body.applicationProblemJson
        }
    }
}
