import Foundation
import Testing

@testable import Domain

@Suite("Debt records")
struct DebtRecordsTests {
    @Test("installments preserve each server status")
    func installments() {
        let date = Date(timeIntervalSince1970: 1_800_000_000)
        let statuses: [DebtInstallment.Status] = [.upcoming, .dueSoon, .paid, .onTime, .late]
        let rows = statuses.enumerated().map { index, status in
            DebtInstallment(id: "installment-\(index)", dueAt: date, amount: index + 1, status: status)
        }
        #expect(rows.map(\.status) == statuses)
        #expect(rows.first?.id == "installment-0")
        #expect(rows.last?.amount == 5)
    }

    @Test("payments preserve the server's timing classification")
    func payments() {
        let date = Date(timeIntervalSince1970: 1_800_000_000)
        let onTime = DebtPayment(id: "p1", paidAt: date, amount: 100, timing: .onTime)
        let late = DebtPayment(id: "p2", paidAt: date, amount: 200, timing: .late)
        #expect(onTime.timing == .onTime)
        #expect(late.timing == .late)
        #expect(onTime.amount + late.amount == 300)
    }

    @Test("payment request has a reusable idempotency key")
    func paymentRequest() {
        let id = UUID(
            uuid: (0x3B, 0x12, 0xF1, 0xDF, 0x52, 0x32, 0x48, 0x04, 0x89, 0x7E, 0x91, 0x7B, 0xF3, 0x97, 0x61, 0x8A))
        let request = DebtPaymentRequest(paymentId: id, amount: 50_000)
        #expect(request.paymentId == id)
        #expect(request.amount == 50_000)
        let zero = UUID(uuid: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0))
        #expect(DebtPaymentRequest(amount: 1).paymentId != zero)
    }

    @Test("score estimates contain both values from the engine")
    func scoreEstimate() {
        let estimate = DebtScoreEstimate(current: 66, afterPayoff: 71)
        #expect(estimate.current == 66)
        #expect(estimate.afterPayoff == 71)
    }
}
