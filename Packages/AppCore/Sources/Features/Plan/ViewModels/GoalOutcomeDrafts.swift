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
