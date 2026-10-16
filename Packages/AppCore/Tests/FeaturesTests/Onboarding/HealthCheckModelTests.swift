import Domain
import Testing

@testable import Features

@MainActor
@Suite("HealthCheckModel")
struct HealthCheckModelTests {
    private func filled(_ service: FakeOnboardingService, onScored: @escaping (ScoreReport) -> Void = { _ in })
        -> HealthCheckModel
    {
        let model = HealthCheckModel(service: service, onScored: onScored)
        model.income = "7500000"
        model.payday = .endOfMonth
        model.expenses = "4200000"
        model.debts.add()
        model.debts.form.name = "Paylater A"
        model.debts.form.remaining = "420000"
        model.debts.form.instalment = "210000"
        model.debts.saveForm()
        model.emergencyFund = "3360000"
        model.monthlySavings = "600000"
        model.otherAssets = "1000000"
        model.propertyAssets = "15000000"
        model.protection.dependents = 5
        model.protection.maritalStatus = .married
        model.protection.toggle(.bpjsHealth)
        return model
    }

    @Test("amounts are grouped as typed and sent as whole rupiah with every other answer")
    func answers() {
        let model = filled(FakeOnboardingService())
        #expect(model.income == "7.500.000")
        let answers = model.answers
        #expect(answers.netMonthlyIncome == 7_500_000)
        #expect(answers.payday == .endOfMonth)
        #expect(answers.essentialMonthlyExpenses == 4_200_000)
        #expect(answers.debts.map(\.name) == ["Paylater A"])
        #expect(answers.emergencyFund == 3_360_000 && answers.monthlySavings == 600_000)
        #expect(answers.otherAssets == 1_000_000 && answers.propertyAssets == 15_000_000)
        #expect(answers.dependents == 3)
        #expect(answers.maritalStatus == .married)
        #expect(answers.protections == [.bpjsHealth])
    }

    @Test("skipping a step empties its answers")
    func skip() {
        let model = filled(FakeOnboardingService())
        for step in HealthCheckStep.allCases { model.skip(step) }
        let answers = model.answers
        #expect(answers.netMonthlyIncome == nil && answers.essentialMonthlyExpenses == nil)
        #expect(answers.debts.isEmpty)
        #expect(answers.emergencyFund == nil && answers.monthlySavings == nil)
        #expect(answers.otherAssets == nil && answers.propertyAssets == nil)
        #expect(answers.protections == [.bpjsHealth])
    }

    @Test("Lihat Hasilku sends the answers and hands on the report")
    func submit() async {
        let service = FakeOnboardingService()
        var report: ScoreReport?
        let model = filled(service) { report = $0 }
        await model.submit()
        #expect(await service.calls == [.healthCheck(model.answers)])
        #expect(report == FakeOnboardingService.report)
        #expect(model.phase == .editing)
    }

    @Test("a refusal shows the problem")
    func fails() async {
        let model = filled(FakeOnboardingService(failures: 1)) { _ in Issue.record("scored") }
        await model.submit()
        #expect(model.phase == .failed(FakeOnboardingService.problem))
    }
}
