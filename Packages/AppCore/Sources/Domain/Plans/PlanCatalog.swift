/** `GET /plans`: every plan's terms and the plan the person is on now. */
package struct PlanCatalog: Hashable, Sendable {
    /** The plan the person is on, and its period when it is paid. */
    package struct Current: Hashable, Sendable {
        /** The plan. */
        package let plan: PlanID
        /** How it is paid; nil on Kira Gratis. */
        package let period: BillingPeriod?

        /** The current plan as the API sends it. */
        package init(plan: PlanID, period: BillingPeriod?) {
            self.plan = plan
            self.period = period
        }
    }

    /** The terms of each plan, Gratis first. */
    package let plans: [PlanTerms]
    /** The person's plan. */
    package let current: Current

    /** The catalog as the API sends it. */
    package init(plans: [PlanTerms], current: Current) {
        self.plans = plans
        self.current = current
    }

    /** The terms of one plan, or nil when the API left it out. */
    package func terms(for plan: PlanID) -> PlanTerms? {
        plans.first { $0.id == plan }
    }
}
