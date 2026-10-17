/** DebtEntry holds one debt of the health check (ONB-11b). */
import Foundation
import Testing

@testable import Domain

@Suite("DebtEntry")
struct DebtEntryTests {
    @Test("keeps every field, a new id unless one is given and no tenor by default")
    func fields() {
        let id = UUID()
        let entry = DebtEntry(
            id: id, kind: .vehicle, name: "Cicilan Motor", remaining: 12_740_000, monthlyInstalment: 910_000,
            remainingTenorMonths: 14, annualInterestRate: 24.5, dueDay: 5)
        #expect(entry.id == id)
        #expect(entry.kind == .vehicle)
        #expect(entry.name == "Cicilan Motor")
        #expect(entry.remaining == 12_740_000)
        #expect(entry.monthlyInstalment == 910_000)
        #expect(entry.remainingTenorMonths == 14)
        #expect(entry.annualInterestRate == 24.5 && entry.dueDay == 5)
        let other = DebtEntry(kind: .paylater, name: "Paylater A", remaining: 420_000, monthlyInstalment: 210_000)
        #expect(other.id != id)
        #expect(other.remainingTenorMonths == nil)
        #expect(other.annualInterestRate == nil && other.dueDay == nil)
    }
}
