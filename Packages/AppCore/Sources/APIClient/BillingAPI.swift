import Domain

/** Plans, the simulated checkout, the subscription, invoices and gifts. */
extension KiraAPI {
    /** The three plans and the one in force (`GET /api/plans`). */
    package func listPlans() async throws -> PlanCatalog {
        try await client.listPlans().catalog()
    }

    /**
     Buys Muda or Plus, simulated (`POST /api/billing/checkout`). Gratis cannot be bought: asking for
     it throws `VALIDATION_FAILED` without a request.
     */
    package func checkout(
        plan: PlanID, period: BillingPeriod, paymentMethod: PaymentMethod
    ) async throws -> Subscription {
        guard let paid = Components.Schemas.Checkout.PlanPayload(rawValue: plan.rawValue) else {
            throw AppProblem(code: ProblemCode.validationFailed.rawValue)
        }
        let body = Components.Schemas.Checkout(
            plan: paid, period: try bridged(period), paymentMethod: try bridged(paymentMethod))
        return try await client.checkout(body: .json(body)).subscription()
    }

    /** The paid plan (`GET /api/subscription`); 404 `SUBSCRIPTION_NOT_FOUND` on Gratis. */
    package func getSubscription() async throws -> Subscription {
        try await client.getSubscription().subscription()
    }

    /** Ends the plan at the period's end (`POST /api/subscription/cancel`). */
    package func cancelSubscription() async throws -> Subscription {
        try await client.cancelSubscription().subscription()
    }

    /** Changes how the plan is paid (`PUT /api/subscription/payment-method`). */
    package func changePaymentMethod(_ method: PaymentMethod) async throws -> Subscription {
        let body = Components.Schemas.PaymentMethodChange(paymentMethod: try bridged(method))
        return try await client.changePaymentMethod(body: .json(body)).subscription()
    }

    /** The latest invoices, newest first (`GET /api/billing/invoices`). */
    package func listInvoices() async throws -> [Invoice] {
        try await client.listInvoices().invoices()
    }

    /** Gifts months of Kira Plus to Beasiswa Kira, simulated (`POST /api/billing/gifts`). */
    package func giftMonths(_ length: GiftLength, paymentMethod: PaymentMethod) async throws -> Gift {
        let body = Components.Schemas.GiftRequest(
            months: Double(length.rawValue), paymentMethod: try bridged(paymentMethod))
        return try await client.giftMonths(body: .json(body)).gift()
    }
}
