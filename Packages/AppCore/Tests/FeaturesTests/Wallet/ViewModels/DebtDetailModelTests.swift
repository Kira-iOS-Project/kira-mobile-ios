import APIClient
import Domain
import Foundation
import Testing

@testable import Features

/** Detail Utang's API boundary: the debt, or the error a test sets. */
private actor FakeDebtDetailService: DebtDetailService {
    var failure: (any Error)?
    private(set) var asked: [String] = []

    func fail(with error: (any Error)?) { failure = error }

    func debt(id: String) throws -> DebtDetail {
        asked.append(id)
        if let failure { throw failure }
        return DebtDetail(
            id: id, name: "Paylater A", kind: .paylater, remaining: 420_000, totalAmount: 1_260_000,
            paidAmount: 840_000, instalmentsPaid: 4, instalmentsTotal: 6, monthlyInstalment: 210_000, dueDate: nil,
            payments: [], nextStep: nil)
    }
}

@MainActor
@Suite("DebtDetailModel")
struct DebtDetailModelTests {
    @Test("loads the debt it was opened on")
    func loads() async {
        let service = FakeDebtDetailService()
        let model = DebtDetailModel(id: "paylater-a", service: service)
        await model.load()
        #expect(model.phase.value?.remaining == 420_000 && (await service.asked) == ["paylater-a"])
    }

    @Test(
        "a debt that is gone, a refused or a lost load shows its problem, and Coba Lagi loads again",
        arguments: [
            AppProblem(code: "PAYOFF_DEBT_NOT_FOUND") as any Error, AppProblem(code: "VALIDATION_FAILED"),
            URLError(.notConnectedToInternet),
        ])
    func fails(error: any Error) async {
        let service = FakeDebtDetailService()
        await service.fail(with: error)
        let model = DebtDetailModel(id: "gone", service: service)
        await model.load()
        guard case .failed(let problem) = model.phase else { Issue.record("expected failed"); return }
        #expect(problem == AppProblem(error))
        await service.fail(with: nil)
        await model.load()
        #expect(model.phase.value != nil)
    }
}
