/** DebtKind spells the backend's DEBT_KIND values and knows which are consumer debt (ONB-11). */
import Testing

@testable import Domain

@Suite("DebtKind")
struct DebtKindTests {
    @Test("raw values are the backend's")
    func rawValues() {
        #expect(
            DebtKind.allCases.map(\.rawValue) == [
                "paylater", "online_loan", "credit_card", "vehicle", "mortgage", "family_loan",
            ])
    }

    @Test("paylater, online loans and credit cards are consumer debt; the rest are not")
    func isConsumer() {
        #expect(DebtKind.allCases.filter(\.isConsumer) == [.paylater, .onlineLoan, .creditCard])
    }
}
