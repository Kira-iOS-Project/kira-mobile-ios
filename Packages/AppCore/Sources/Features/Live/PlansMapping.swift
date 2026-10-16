import APIClient
import Domain

/** Billing's answers in the Domain's values (`GET /plans`, the subscription, invoices). */
extension PlanCatalog {
    /** Every plan's terms and the person's plan. */
    init(_ catalog: PlanCatalogDTO) throws {
        self.init(
            plans: catalog.plans.map {
                PlanTerms(
                    id: $0.id, monthlyPrice: $0.monthlyPrice, yearlyPrice: $0.yearlyPrice, aiMessages: $0.aiMessages,
                    receipts: $0.receipts, voiceSeconds: $0.voiceSeconds, voiceAndImport: $0.voiceAndImport)
            },
            current: Current(plan: catalog.current, period: try catalog.currentPeriod.map { try Bridge.value($0) }))
    }
}

extension Subscription {
    /** The subscription; its period started on the WIB day of `currentPeriodStart`. */
    init(_ dto: SubscriptionDTO) throws {
        self.init(
            id: dto.id, plan: dto.plan, period: try Bridge.value(dto.period), source: try Bridge.value(dto.source),
            price: dto.price, paymentMethod: try dto.paymentMethod.map { try Bridge.value($0) },
            currentPeriodStart: CalendarDay(dto.currentPeriodStart), renewsOn: try Bridge.day(dto.renewsOn),
            reminderOn: try Bridge.day(dto.reminderOn), cancelAtPeriodEnd: dto.cancelAtPeriodEnd,
            usage: try PlanUsage(dto.usage))
    }
}

extension PlanUsage {
    /** The quotas used this period. */
    init(_ usage: UsageDTO) throws {
        self.init(
            aiMessages: Quota(used: usage.aiMessages.used, limit: usage.aiMessages.limit),
            receipts: Quota(used: usage.receipts.used, limit: usage.receipts.limit),
            voiceSeconds: Quota(used: usage.voiceSeconds.used, limit: usage.voiceSeconds.limit),
            resetsOn: try Bridge.day(usage.resetsOn))
    }
}

extension Invoice {
    /** One payment. */
    init(_ dto: InvoiceDTO) throws {
        self.init(
            id: dto.id, plan: dto.plan, period: try Bridge.value(dto.period), amount: dto.amount,
            paymentMethod: try Bridge.value(dto.paymentMethod), periodStart: try Bridge.day(dto.periodStart))
    }
}

extension ScholarshipOverview {
    /** Whether the person may apply, this month's places, and their application. */
    init(_ dto: ScholarshipDTO) throws {
        self.init(
            eligible: dto.eligible, ineligibleReason: try dto.ineligibleReason.map { try Bridge.value($0) },
            quotaRemaining: dto.remainingPlaces, quotaTotal: dto.totalPlaces,
            application: try dto.application.map(ScholarshipApplication.init))
    }
}

extension ScholarshipApplication {
    /** An application; its decision once the review gave every date of it. */
    init(_ dto: ScholarshipApplicationDTO) throws {
        self.init(
            id: dto.id, status: try Bridge.value(dto.status),
            situations: try dto.situations.map { try Bridge.value($0) }, story: dto.story,
            submittedAt: dto.submittedAt, decideBy: try Bridge.day(dto.decideBy), decision: try Self.decision(dto))
    }

    private static func decision(_ dto: ScholarshipApplicationDTO) throws -> Decision? {
        guard let decidedAt = dto.decidedAt, let start = dto.grantStart, let end = dto.grantEnd,
            let extensionFrom = dto.extensionFrom
        else { return nil }
        return Decision(
            decidedAt: CalendarDay(decidedAt), grantStart: try Bridge.day(start), grantEnd: try Bridge.day(end),
            extensionFrom: try Bridge.day(extensionFrom))
    }
}
