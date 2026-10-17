import Domain
import Foundation

/** Debt detail and payment operations for the wallet screens. */
extension KiraAPI {
    package func getDebt(id: String) async throws -> DebtDetail {
        try await client.getDebtDetail(path: .init(id: id)).debtDetail()
    }

    /** Uses the existing payoff payment route, then fetches the engine's updated detail. */
    package func payDebt(id: String, request: DebtPaymentRequest) async throws -> DebtDetail {
        let body = Components.Schemas.RecordDebtPayment(
            amount: request.amount, paymentId: request.paymentId.uuidString.lowercased())
        _ = try await client.recordDebtPayment(path: .init(id: id), body: .json(body)).recorded()
        return try await getDebt(id: id)
    }
}
