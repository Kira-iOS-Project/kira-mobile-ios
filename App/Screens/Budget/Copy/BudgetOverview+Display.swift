/**
 What Budget (board Budget, lane UNG-04) writes from the server's numbers: the money left a day until
 payday, the share of the pay spent, and each category's tag. No red and no warning anywhere: a
 category at 90% gets a turmeric tag with what is left, a paid Tagihan a healthy one.
 */
import Domain

extension BudgetOverview {
    /** "Sekitar Rp184.000,00 per hari": what is left, spread over the days until payday (at least one). */
    var perDay: Int { max(remaining, 0) / max(period.daysUntilPayday, 1) }

    /** What the hero counts as used: the pay minus what the server says is left (not only the categories). */
    var used: Int { max(income - remaining, 0) }

    /** "75% dari gaji": the share of the pay used so far, rounded down. */
    var spentPercent: Int { income > 0 ? used * 100 / income : 0 }

    /** "masih aman, kok" beside Per Kategori: shown while no category has gone past its plan. */
    var isWithinPlan: Bool { !allocations.contains { $0.spent > $0.amount } }
}

extension BudgetAllocation {
    /** The tag a row carries, if any. */
    enum RowTag: Equatable {
        /** "Sisa Rp60.000,00": 90% or more used; what is left, never below zero. */
        case left(Int)
        /** "Lunas": the Tagihan category fully paid. */
        case paid
    }

    /** Tagihan with its plan fully spent counts as paid, with a healthy bar. */
    var isPaidBill: Bool { category == .bills && amount > 0 && spent >= amount }

    /** The row's tag: Lunas for a paid Tagihan, else the amount left once 90% is used. */
    var rowTag: RowTag? {
        if isPaidBill { return .paid }
        return isNearLimit ? .left(max(amount - spent, 0)) : nil
    }
}
