/**
 One of the person's debts as Naskah Pengajuan Keringanan (PED-09) lists them: the lender's name and
 the monthly instalment, from the health check's debts (`GET /debts`).
 */
package struct CareDebt: Identifiable, Hashable, Sendable {
    /** The debt's id. */
    package let id: String
    /** The lender as the person named it ("Paylater B"). */
    package let name: String
    /** The kind of debt. */
    package let kind: DebtKind
    /** What is left to pay, in whole rupiah. */
    package let remaining: Int
    /** The instalment each month, in whole rupiah. */
    package let monthlyInstalment: Int

    /** A debt with the given fields. */
    package init(id: String, name: String, kind: DebtKind, remaining: Int, monthlyInstalment: Int) {
        self.id = id
        self.name = name
        self.kind = kind
        self.remaining = remaining
        self.monthlyInstalment = monthlyInstalment
    }
}
