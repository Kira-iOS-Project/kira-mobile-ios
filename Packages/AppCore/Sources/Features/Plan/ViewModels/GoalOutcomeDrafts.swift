import Domain

/**
 What Jadikan Pos Budget stores (`POST /goals`) for the goals whose results R2b built: the kind, its
 name, the form's inputs as flat keyed fields, what is saved, the monthly deposit, and the target
 with its date counted from `today`.
 */
extension PriceGoalOutcome {
    /** Kendaraan or Barang Impian (`kind`), named by the person for Barang. */
    package func draft(kind: GoalKind, today: CalendarDay) -> GoalDraft {
        GoalDraft(
            kind: kind, name: name.isEmpty ? (kind == .vehicle ? "Kendaraan" : "Barang Impian") : name,
            inputs: [
                "price": .number(Double(price)), "downPaymentRate": .number(downPayment),
                "inflation": .number(inflation), "months": .number(Double(months)),
                "annualReturn": .number(annualReturn),
            ],
            initialAmount: present, monthlyDeposit: deposit, targetAmount: projection.target,
            targetDate: today.adding(months: months), inBudget: true)
    }
}

extension OtherGoalOutcome {
    /** Lainnya: a yearly deposit is stored as its monthly twelfth. */
    package func draft(today: CalendarDay) -> GoalDraft {
        let monthly = period == .year ? Int((Double(deposit) / 12).rounded()) : deposit
        return GoalDraft(
            kind: .other, name: name,
            inputs: [
                "years": .number(Double(years)), "annualReturn": .number(annualReturn),
                "period": .text(period == .year ? "year" : "month"), "timing": .text(timing == .end ? "end" : "start"),
            ],
            initialAmount: present, monthlyDeposit: monthly, targetAmount: projection.target,
            targetDate: today.adding(years: years), inBudget: true)
    }
}

extension RetirementGoalOutcome {
    /** Dana Pensiun, due when the person retires. */
    package func draft(today: CalendarDay) -> GoalDraft {
        GoalDraft(
            kind: .retirement, name: "Dana Pensiun",
            inputs: [
                "monthlyExpense": .number(Double(monthlyExpense)), "age": .number(Double(age)),
                "years": .number(Double(years)), "inflation": .number(inflation),
                "annualReturn": .number(annualReturn),
            ],
            initialAmount: present, monthlyDeposit: deposit, targetAmount: projection.target,
            targetDate: today.adding(years: years), inBudget: true)
    }
}

extension EducationGoalOutcome {
    /**
     Pendidikan Anak, due when the last stage ends; each stage's figures as "level.<stage>.<field>"
     (the API keeps inputs flat).
     */
    package func draft(today: CalendarDay) -> GoalDraft {
        var inputs: [String: GoalInput] = [
            "childName": .text(childName), "childAge": .number(Double(plan.childAge)),
            "inflation": .number(plan.inflation), "income": .number(Double(plan.income)),
            "annualReturn": plan.annualReturn.map { .number($0) } ?? .empty,
        ]
        for (level, values) in zip(plan.levels, details) {
            let prefix = "level.\(level.stage.key)."
            inputs[prefix + "entryFee"] = .number(Double(level.entryFee))
            inputs[prefix + "fee"] = .number(Double(level.fee))
            inputs[prefix + "feePeriod"] = .text(level.feePeriod.key)
            inputs[prefix + "otherRate"] = .number(level.otherRate)
            inputs[prefix + "region"] = .text(values.region.key)
            inputs[prefix + "school"] = .text(values.school.key)
        }
        return GoalDraft(
            kind: .education, name: "Pendidikan \(childName)", inputs: inputs, initialAmount: plan.present,
            monthlyDeposit: plan.deposit, targetAmount: plan.target(),
            targetDate: today.adding(years: plan.yearsInvesting), inBudget: true)
    }
}

extension EducationStage {
    /** Its key in a goal's inputs. */
    fileprivate var key: String {
        switch self {
        case .primary: "primary"
        case .juniorHigh: "juniorHigh"
        case .seniorHigh: "seniorHigh"
        case .bachelor: "bachelor"
        }
    }
}

extension FeePeriod {
    fileprivate var key: String {
        switch self {
        case .month: "month"
        case .semester: "semester"
        case .year: "year"
        }
    }
}

extension EducationRegion {
    fileprivate var key: String {
        switch self {
        case .jakarta: "jakarta"
        case .java: "java"
        case .outsideJava: "outsideJava"
        case .abroad: "abroad"
        }
    }
}

extension EducationSchool {
    fileprivate var key: String {
        switch self {
        case .public: "public"
        case .private: "private"
        case .nationalPlus: "nationalPlus"
        case .international: "international"
        }
    }
}
