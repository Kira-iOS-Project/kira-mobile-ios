import Domain
import Foundation

/**
 Ubah Tujuan (REN-05): "membuka kalkulator berisi nilai sekarang". Each form opens on the figures a
 goal was saved with: its inputs as Jadikan Pos Budget stored them (`GoalOutcomeDrafts`), with what
 was saved, the monthly deposit and the target from the goal itself. An input the goal lacks leaves
 its field empty, so Hitung waits for it.
 */
package enum GoalEditing {
    /** A stored amount as its field shows it. */
    static func rupiah(_ value: Int?) -> String {
        AmountInput.text(for: value)
    }

    /** A stored fraction (0.045) as its percent field shows it ("4,5"); empty when missing. */
    static func percent(_ value: Double?) -> String {
        guard let value else { return "" }
        let percent = (value * 10_000).rounded() / 100
        let text = percent == percent.rounded() ? String(Int(percent)) : String(percent)
        return text.replacingOccurrences(of: ".", with: ",")
    }

    /** A stored whole count; empty when missing. */
    static func count(_ value: Double?) -> String {
        value.map { String(Int($0.rounded())) } ?? ""
    }
}

extension GoalDetail {
    /** The number stored under `key`; nil when it is missing or not a number. */
    func number(_ key: String) -> Double? {
        if case .number(let value) = inputs[key] { return value }
        return nil
    }

    /** The text stored under `key`; nil when it is missing or not a text. */
    func text(_ key: String) -> String? {
        if case .text(let value) = inputs[key] { return value }
        return nil
    }
}

extension PriceGoalValues {
    /** Kendaraan (`horizon` years) or Barang Impian (months) as `goal` was saved. */
    package init(editing goal: GoalDetail, horizon: PriceGoalModel.Horizon) {
        self.init()
        if goal.summary.kind == .goods { name = goal.summary.name }
        let months = goal.number("months")
        duration = GoalEditing.count(horizon == .years ? months.map { $0 / 12 } : months)
        price = GoalEditing.rupiah(goal.number("price").map { Int($0) })
        downPayment = GoalEditing.percent(goal.number("downPaymentRate"))
        inflation = GoalEditing.percent(goal.number("inflation"))
        present = GoalEditing.rupiah(goal.initialAmount)
        deposit = GoalEditing.rupiah(goal.summary.monthlyDeposit)
        annualReturn = GoalEditing.percent(goal.number("annualReturn"))
    }
}

extension OtherGoalValues {
    /** Lainnya as `goal` was saved; a yearly deposit was stored as its monthly twelfth. */
    package init(editing goal: GoalDetail) {
        self.init()
        name = goal.summary.name
        amount = GoalEditing.rupiah(goal.summary.targetAmount)
        duration = GoalEditing.count(goal.number("years"))
        present = GoalEditing.rupiah(goal.initialAmount)
        period = goal.text("period") == "year" ? .year : .month
        timing = goal.text("timing") == "end" ? .end : .start
        deposit = GoalEditing.rupiah(goal.summary.monthlyDeposit * (period == .year ? 12 : 1))
        annualReturn = GoalEditing.percent(goal.number("annualReturn"))
    }
}

extension RetirementGoalValues {
    /** Dana Pensiun as `goal` was saved: the retirement age is today's age plus the years left. */
    package init(editing goal: GoalDetail) {
        self.init()
        expense = GoalEditing.rupiah(goal.number("monthlyExpense").map { Int($0) })
        age = GoalEditing.count(goal.number("age"))
        if let age = goal.number("age"), let years = goal.number("years") {
            retirementAge = GoalEditing.count(age + years)
        }
        inflation = GoalEditing.percent(goal.number("inflation"))
        present = GoalEditing.rupiah(goal.initialAmount)
        deposit = GoalEditing.rupiah(goal.summary.monthlyDeposit)
        annualReturn = GoalEditing.percent(goal.number("annualReturn"))
    }
}

extension EmergencyFundGoalModel {
    /** Dana Darurat as `goal` was saved. */
    package static func editing(_ goal: GoalDetail) -> EmergencyFundGoalModel {
        let model = EmergencyFundGoalModel()
        model.essential = GoalEditing.rupiah(goal.number("essentialExpense").map { Int($0) })
        if case .flag(let married) = goal.inputs["married"] { model.married = married }
        model.dependants = GoalEditing.count(goal.number("dependants") ?? 0)
        model.months = GoalEditing.count(goal.number("months"))
        model.present = GoalEditing.rupiah(goal.initialAmount)
        model.deposit = GoalEditing.rupiah(goal.summary.monthlyDeposit)
        model.annualReturn = GoalEditing.percent(goal.number("annualReturn"))
        return model
    }
}

extension HouseDownPaymentFormModel {
    /** DP Rumah with its Simulasi KPR as `goal` was saved. */
    package static func editing(_ goal: GoalDetail) -> HouseDownPaymentFormModel {
        HouseDownPaymentFormModel(
            years: GoalEditing.count(goal.number("years")),
            price: GoalEditing.rupiah(goal.number("price").map { Int($0) }),
            downPaymentRate: GoalEditing.percent(goal.number("downPaymentRate")),
            inflation: GoalEditing.percent(goal.number("inflation")), present: GoalEditing.rupiah(goal.initialAmount),
            deposit: GoalEditing.rupiah(goal.summary.monthlyDeposit),
            annualReturn: GoalEditing.percent(goal.number("annualReturn")),
            income: GoalEditing.rupiah(goal.number("income").map { Int($0) }),
            tenorYears: goal.number("tenorYears").map { Int($0) } ?? 20,
            fixRate: GoalEditing.percent(goal.number("fixRate")),
            floatRate: GoalEditing.percent(goal.number("floatRate")),
            fixYears: goal.number("fixYears").map { Int($0) } ?? 3,
            njopTkp: GoalEditing.rupiah(goal.number("njopTkp").map { Int($0) }))
    }
}

extension WeddingFormModel {
    /** Menikah as `goal` was saved: its total in Sederhana, since the rows are not stored. */
    package static func editing(_ goal: GoalDetail) -> WeddingFormModel {
        let model = WeddingFormModel(
            years: GoalEditing.count(goal.number("years")), inflation: GoalEditing.percent(goal.number("inflation")),
            present: GoalEditing.rupiah(goal.initialAmount), deposit: GoalEditing.rupiah(goal.summary.monthlyDeposit),
            annualReturn: GoalEditing.percent(goal.number("annualReturn")))
        model.budgeting = .simple
        model.simpleTotal = GoalEditing.rupiah(goal.number("cost").map { Int($0) })
        return model
    }
}

extension EducationGoalModel {
    /** Pendidikan Anak as `goal` was saved, each stored stage with its own figures. */
    package static func editing(_ goal: GoalDetail) -> EducationGoalModel {
        let model = EducationGoalModel()
        model.childName = goal.text("childName") ?? ""
        model.childAge = GoalEditing.count(goal.number("childAge"))
        model.income = GoalEditing.rupiah(goal.number("income").map { Int($0) })
        model.present = GoalEditing.rupiah(goal.initialAmount)
        model.inflation = GoalEditing.percent(goal.number("inflation"))
        model.deposit = GoalEditing.rupiah(goal.summary.monthlyDeposit)
        model.knowsWhere = goal.number("annualReturn") != nil
        model.annualReturn = GoalEditing.percent(goal.number("annualReturn"))
        let stored = EducationStage.allCases.filter { goal.number("level.\($0.key).fee") != nil }
        if let first = stored.first, let last = stored.last {
            model.lastStage = last
            model.firstStage = first
        }
        for stage in stored {
            let prefix = "level.\(stage.key)."
            let average = EducationStageValues.average(for: stage)
            model.save(
                EducationStageValues(
                    region: EducationRegion.allCases.first { $0.key == goal.text(prefix + "region") } ?? average.region,
                    school: EducationSchool.allCases.first { $0.key == goal.text(prefix + "school") } ?? average.school,
                    entryFee: GoalEditing.rupiah(goal.number(prefix + "entryFee").map { Int($0) }),
                    fee: GoalEditing.rupiah(goal.number(prefix + "fee").map { Int($0) }),
                    feePeriod: [FeePeriod.month, .semester, .year].first { $0.key == goal.text(prefix + "feePeriod") }
                        ?? average.feePeriod,
                    otherRate: GoalEditing.percent(goal.number(prefix + "otherRate"))),
                for: stage)
        }
        return model
    }
}
