/**
 One of the person's debts as Naskah Pengajuan Keringanan (PED-09) lists them: the lender's name and
 the monthly instalment, from the health check's debts (`GET /debts`).
 */
package struct CareDebt: Identifiable, Hashable, Sendable {
    /** The debt's id. */
    package let id: String
    /** The lender as the person named it ("Paylater B"). */
    package let name: String
    /** The instalment each month, in whole rupiah. */
    package let monthlyInstalment: Int

    /** A debt with the given fields. */
    package init(id: String, name: String, monthlyInstalment: Int) {
        self.id = id
        self.name = name
        self.monthlyInstalment = monthlyInstalment
    }
}
