/** `GET /plans`: every plan's terms and the plan the person is on now. */
package struct PlanCatalog: Hashable, Sendable {
    /** The plan the person is on. */
    package struct Current: Hashable, Sendable {
        /** The plan. */
        package let plan: PlanID

        /** The current plan as the API sends it. */
        package init(plan: PlanID) {
            self.plan = plan
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
