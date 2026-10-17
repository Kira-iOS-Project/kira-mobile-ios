/**
 One debt account in full (UNG-03 Detail Utang, `GET /debts/{id}`): what is left, how much of the
 total is paid and in how many instalments, the monthly instalment and the next due date, the
 payments made (newest first), and the payoff engine's next step. Amounts are whole rupiah. A debt
 that is gone, or someone else's, answers 404 `PAYOFF_DEBT_NOT_FOUND`.
 */
package struct DebtDetail: Hashable, Identifiable, Sendable {
    /** The debt's id. */
    package let id: String
    /** The name the person gave it ("Paylater A"). */
    package let name: String
    /** What kind of debt it is. */
    package let kind: DebtKind
    /** Sisa utang. */
    package let remaining: Int
    /** The total owed at the start. */
    package let totalAmount: Int
    /** Sudah dibayar. */
    package let paidAmount: Int
    /** Instalments paid so far; nil when the debt has no fixed count. */
    package let instalmentsPaid: Int?
    /** All the instalments; nil when the debt has no fixed count. */
    package let instalmentsTotal: Int?
    /** Cicilan per Bulan. */
    package let monthlyInstalment: Int
    /** The next due date; nil when none is set. */
    package let dueDate: CalendarDay?
    /** Riwayat Pembayaran, newest first. */
    package let payments: [DebtInstalment]
    /** Langkah Berikutnya; nil when the engine has nothing to suggest. */
    package let nextStep: DebtNextStep?

    /** A debt with the given parts. */
    package init(
        id: String, name: String, kind: DebtKind, remaining: Int, totalAmount: Int, paidAmount: Int,
        instalmentsPaid: Int?, instalmentsTotal: Int?, monthlyInstalment: Int, dueDate: CalendarDay?,
        payments: [DebtInstalment], nextStep: DebtNextStep?
    ) {
        self.id = id
        self.name = name
        self.kind = kind
        self.remaining = remaining
        self.totalAmount = totalAmount
        self.paidAmount = paidAmount
        self.instalmentsPaid = instalmentsPaid
        self.instalmentsTotal = instalmentsTotal
        self.monthlyInstalment = monthlyInstalment
        self.dueDate = dueDate
        self.payments = payments
        self.nextStep = nextStep
    }

    /** The instalments still to pay ("tinggal dua cicilan lagi"); nil without a fixed count. */
    package var instalmentsLeft: Int? {
        guard let instalmentsPaid, let instalmentsTotal else { return nil }
        return max(instalmentsTotal - instalmentsPaid, 0)
    }

    /** Days from `today` to the due date ("10 Hari Lagi"); nil without one, negative once past. */
    package func daysUntilDue(from today: CalendarDay) -> Int? {
        dueDate.map { today.days(to: $0) }
    }
}

/** One instalment paid ("Cicilan ke-4, dibayar 25 September 2026, Tepat Waktu"). */
package struct DebtInstalment: Hashable, Identifiable, Sendable {
    /** The payment's id. */
    package let id: String
    /** Which instalment it was, from 1. */
    package let number: Int
    /** Whole rupiah. */
    package let amount: Int
    /** The day it was paid. */
    package let paidOn: CalendarDay
    /** Whether it was paid by its due date. */
    package let onTime: Bool

    /** Instalment `number` of `amount`, paid on `paidOn`. */
    package init(id: String, number: Int, amount: Int, paidOn: CalendarDay, onTime: Bool) {
        self.id = id
        self.number = number
        self.amount = amount
        self.paidOn = paidOn
        self.onTime = onTime
    }
}

/**
 Langkah Berikutnya: the payoff engine's suggestion for this debt ("Prioritas 1 dari 3 · Lunasi Bulan
 Ini: tambah Rp210.000,00 di cicilan 25 Oktober 2026, lunas sebulan lebih awal; Kira Score 66 → 71").
 */
package struct DebtNextStep: Hashable, Sendable {
    /** Its place among the person's debts, from 1. */
    package let priority: Int
    /** How many debts are ranked. */
    package let priorityOf: Int
    /** What to add to the next instalment. */
    package let extraAmount: Int
    /** The instalment to add it to; nil when its date is not known. */
    package let payOn: CalendarDay?
    /** The Kira Score now; nil before the health check. */
    package let scoreBefore: Int?
    /** The estimated Kira Score after; nil before the health check. */
    package let scoreAfter: Int?

    /** A next step with the given parts. */
    package init(
        priority: Int, priorityOf: Int, extraAmount: Int, payOn: CalendarDay?, scoreBefore: Int?,
        scoreAfter: Int?
    ) {
        self.priority = priority
        self.priorityOf = priorityOf
        self.extraAmount = extraAmount
        self.payOn = payOn
        self.scoreBefore = scoreBefore
        self.scoreAfter = scoreAfter
    }
}
