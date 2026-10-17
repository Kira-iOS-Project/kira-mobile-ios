import Domain

/** The REN schemas mapped to the Domain's Plan models; a day or a kind the app cannot read is the generic problem. */

private func day(_ text: String) throws -> CalendarDay {
    guard let day = CalendarDay(iso: text) else { throw AppProblem() }
    return day
}

extension PlanOverview {
    init(_ dto: Components.Schemas.PlanOverview) throws {
        let prefill = dto.prefill
        self.init(
            ladder: try dto.ladder.map(LadderStep.init), goals: try dto.goals.map(GoalSummary.init),
            prefill: PlanPrefill(
                essentialExpense: prefill.essentialExpense, emergencyFund: prefill.emergencyFund,
                maritalStatus: prefill.married.map { $0 ? .married : .single }, dependants: prefill.dependants,
                monthlyIncome: prefill.monthlyIncome))
    }
}

extension LadderStep {
    init(_ dto: Components.Schemas.LadderStep) throws {
        guard let key = LadderKey(rawValue: dto.key.rawValue), let status = LadderStatus(rawValue: dto.status.rawValue)
        else { throw AppProblem() }
        let detail = dto.detail
        self.init(
            step: dto.step, key: key, status: status,
            detail: LadderDetail(
                debtName: detail.debtName, amount: detail.amount, target: detail.target, multiple: detail.multiple,
                targetMultiple: detail.targetMultiple, health: detail.health.map { $0 ? .held : .missing },
                incomeCover: detail.incomeCover.map { $0 ? .held : .missing }))
    }
}

extension GoalSummary {
    init(_ dto: Components.Schemas.GoalSummary) throws {
        guard let kind = GoalKind(rawValue: dto.kind.rawValue) else { throw AppProblem() }
        self.init(
            id: dto.id, kind: kind, name: dto.name, targetAmount: dto.targetAmount, targetDate: try day(dto.targetDate),
            monthlyDeposit: dto.monthlyDeposit, savedAmount: dto.savedAmount)
    }
}

extension GoalDetail {
    init(_ dto: Components.Schemas.Goal) throws {
        self.init(
            summary: try GoalSummary(dto.value1), inputs: dto.value2.inputs.domain,
            initialAmount: dto.value2.initialAmount, inBudget: dto.value2.inBudget)
    }

    init(_ dto: Components.Schemas.GoalDetail) throws {
        let goal = try GoalDetail(dto.value1)
        let deposits = try dto.value2.deposits.map {
            GoalDeposit(id: $0.id, amount: $0.amount, depositedOn: try day($0.depositedOn))
        }
        let milestones = try dto.value2.milestones.map { milestone -> GoalMilestone in
            guard let key = MilestoneKey(rawValue: milestone.key.rawValue) else { throw AppProblem() }
            return GoalMilestone(
                key: key, amount: milestone.amount, reachedOn: try milestone.reachedOn.map { try day($0) })
        }
        self.init(
            summary: goal.summary, inputs: goal.inputs, initialAmount: goal.initialAmount, inBudget: goal.inBudget,
            deposits: deposits, milestones: milestones)
    }
}

extension GoalDeposit {
    init(_ dto: Components.Schemas.GoalDeposit) throws {
        self.init(id: dto.id, amount: dto.amount, depositedOn: try day(dto.depositedOn))
    }
}

extension Components.Schemas.GoalInputs {
    /** The inputs as the Domain names them: a number, a text or a flag; an empty input is left out. */
    var domain: [String: GoalInput] {
        additionalProperties.compactMapValues { value in
            if let number = value.value1 { return .number(number) }
            if let text = value.value2 { return .text(text) }
            return value.value3.map(GoalInput.flag)
        }
    }

    init(_ inputs: [String: GoalInput]) {
        self.init(
            additionalProperties: inputs.compactMapValues { input in
                switch input {
                case .number(let number): .init(value1: number)
                case .text(let text): .init(value2: text)
                case .flag(let flag): .init(value3: flag)
                case .empty: nil
                }
            })
    }
}

extension Components.Schemas.CreateGoal {
    init(_ draft: GoalDraft) {
        self.init(
            kind: .init(draft.kind), name: draft.name,
            inputs: .init(draft.inputs), initialAmount: draft.initialAmount, monthlyDeposit: draft.monthlyDeposit,
            targetAmount: draft.targetAmount, targetDate: draft.targetDate.iso, inBudget: draft.inBudget)
    }
}

extension Components.Schemas.UpdateGoal {
    /** Every field of `draft` but its kind, which a goal keeps. */
    init(_ draft: GoalDraft) {
        self.init(
            name: draft.name, inputs: .init(draft.inputs), initialAmount: draft.initialAmount,
            monthlyDeposit: draft.monthlyDeposit, targetAmount: draft.targetAmount, targetDate: draft.targetDate.iso,
            inBudget: draft.inBudget)
    }
}

extension Components.Schemas.CreateGoal.KindPayload {
    /** The API's name of `kind`. Every Domain kind has one, so a new kind fails the build here. */
    init(_ kind: GoalKind) {
        self =
            switch kind {
            case .emergencyFund: .emergencyFund
            case .houseDownPayment: .houseDp
            case .education: .education
            case .wedding: .wedding
            case .retirement: .retirement
            case .vehicle: .vehicle
            case .goods: .goods
            case .other: .other
            }
    }
}
