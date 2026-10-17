/**
 What Budget per Kategori (board Budget, lane UNG-04) reads from the server's numbers: the money left
 a day until payday, the share of the pay used, whether every category is within its plan, and each
 row's tag. No red and no warning: a category at 90% gets "Sisa Rp…", a paid Tagihan "Lunas".
 */
extension BudgetOverview {
    /** "Sekitar Rp184.000,00 per hari": what is left, never below zero, over the days until payday (at least one). */
    package var perDay: Int { max(remaining, 0) / max(period.daysUntilPayday, 1) }

    /** What the hero counts as used: the pay minus what the server says is left, not only the categories. */
    package var used: Int { max(income - remaining, 0) }

    /** "75% dari gaji": the share of the pay used so far, rounded down; zero without a pay. */
    package var spentPercent: Int { income > 0 ? used * 100 / income : 0 }

    /** "masih aman, kok" beside Per Kategori: true while no category has gone past its plan. */
    package var isWithinPlan: Bool { !allocations.contains { $0.spent > $0.amount } }
}

/** The tag a Budget row carries. */
package enum BudgetRowTag: Equatable, Sendable {
    /** "Sisa Rp60.000,00": 90% or more used; what is left, never below zero. */
    case left(Int)
    /** "Lunas": the Tagihan category fully paid. */
    case paid
}

extension BudgetAllocation {
    /** Tagihan with its whole plan spent counts as paid, with a healthy bar. */
    package var isPaidBill: Bool { category == .bills && amount > 0 && spent >= amount }

    /** The row's tag: Lunas for a paid Tagihan, else what is left once 90% is used, else none. */
    package var rowTag: BudgetRowTag? {
        if isPaidBill { return .paid }
        return isNearLimit ? .left(max(amount - spent, 0)) : nil
    }
}
