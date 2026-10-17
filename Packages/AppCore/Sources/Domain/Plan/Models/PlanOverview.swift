/**
 Rencana (REN-01, `GET /plan`): the four-step ladder, the goals, and what the app already knows for
 a new goal's form. The API's riskProfile is not read: the Rencana board has no state that shows it.
 */
package struct PlanOverview: Hashable, Sendable {
    /** The four steps, in order. */
    package var ladder: [LadderStep]
    /** The goals, as `GET /goals` lists them. */
    package var goals: [GoalSummary]
    /** What a new goal's form starts from. */
    package var prefill: PlanPrefill

    /** An overview with the given parts. */
    package init(ladder: [LadderStep], goals: [GoalSummary], prefill: PlanPrefill) {
        self.ladder = ladder
        self.goals = goals
        self.prefill = prefill
    }
}

/** A step of the ladder: which one, how far along, and the numbers behind it. */
package struct LadderStep: Hashable, Sendable {
    /** 1 to 4. */
    package let step: Int
    /** Which step it is. */
    package let key: LadderKey
    /** How far along. */
    package let status: LadderStatus
    /** The numbers the step shows. */
    package let detail: LadderDetail

    /** Step `step` with its key, status and detail. */
    package init(step: Int, key: LadderKey, status: LadderStatus, detail: LadderDetail = LadderDetail()) {
        self.step = step
        self.key = key
        self.status = status
        self.detail = detail
    }
}

/** A ladder step's key, as `GET /plan` names it. */
package enum LadderKey: String, CaseIterable, Hashable, Sendable {
    /** 1. Lunasi utang mahal. */
    case expensiveDebt = "pay_off_debt"
    /** 2. Dana darurat. */
    case emergencyFund = "emergency_fund"
    /** 3. Proteksi. */
    case protection
    /** 4. Investasi. */
    case investing = "invest"
}

/** How far along a ladder step is. */
package enum LadderStatus: String, CaseIterable, Hashable, Sendable {
    /** Sudah Aman. */
    case done
    /** Sedang Berjalan. */
    case current
    /** Still ahead. */
    case todo
}

/** What a ladder step shows; each part is nil where the step has none or it is not known. */
package struct LadderDetail: Hashable, Sendable {
    /** Step 1: the account being paid off ("Paylater A"). */
    package var debtName: String?
    /** Step 1: consumer debt left; step 2: the emergency fund now. Whole rupiah. */
    package var amount: Int?
    /** Step 2: the target. Whole rupiah. */
    package var target: Int?
    /** Step 2: the fund over essential spending, one decimal ("Sekarang 1,1×"). */
    package var multiple: Double?
    /** Step 2: the target's multiple: 6 single, 9 married, +3 a dependant, 15 at most. */
    package var targetMultiple: Int?
    /** Step 3: health cover. */
    package var health: Cover?
    /** Step 3: income cover. */
    package var incomeCover: Cover?

    /** A detail with what is known. */
    package init(
        debtName: String? = nil, amount: Int? = nil, target: Int? = nil, multiple: Double? = nil,
        targetMultiple: Int? = nil, health: Cover? = nil, incomeCover: Cover? = nil
    ) {
        self.debtName = debtName
        self.amount = amount
        self.target = target
        self.multiple = multiple
        self.targetMultiple = targetMultiple
        self.health = health
        self.incomeCover = incomeCover
    }
}

/** Whether a cover is held (the API's true or false). */
package enum Cover: String, CaseIterable, Hashable, Sendable {
    /** Held. */
    case held
    /** Not held. */
    case missing
}

/** The person's risk profile from Kenali Profil Risikomu (REN-06, REN-07). */
package enum RiskProfile: String, CaseIterable, Hashable, Sendable {
    /** Konservatif. */
    case conservative
    /** Moderat. */
    case moderate
    /** Agresif. */
    case aggressive
}

/**
 What a new goal's form starts from: the average essential spending of the last three months (else
 the health check's), the emergency fund, whether the person is married, their dependants and net
 monthly income. Each is nil when the app does not know it.
 */
package struct PlanPrefill: Hashable, Sendable {
    /** Whole rupiah per month. */
    package var essentialExpense: Int?
    /** Whole rupiah. */
    package var emergencyFund: Int?
    /** Belum menikah or menikah (the API's `married`). */
    package var maritalStatus: MaritalStatus?
    /** How many people depend on the person. */
    package var dependants: Int?
    /** The health check's net monthly income, whole rupiah. */
    package var monthlyIncome: Int?

    /** A prefill with what is known. */
    package init(
        essentialExpense: Int? = nil, emergencyFund: Int? = nil, maritalStatus: MaritalStatus? = nil,
        dependants: Int? = nil, monthlyIncome: Int? = nil
    ) {
        self.essentialExpense = essentialExpense
        self.emergencyFund = emergencyFund
        self.maritalStatus = maritalStatus
        self.dependants = dependants
        self.monthlyIncome = monthlyIncome
    }
}
