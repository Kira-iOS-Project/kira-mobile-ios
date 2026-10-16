import Testing

@testable import Features

@Suite("HealthCheckStep")
struct HealthCheckStepTests {
    @Test("six steps numbered 1 to 6, each leading to the next")
    func order() {
        #expect(HealthCheckStep.total == 6)
        #expect(HealthCheckStep.allCases.map(\.number) == [1, 2, 3, 4, 5, 6])
        #expect(HealthCheckStep.income.next == .expenses)
        #expect(HealthCheckStep.assets.next == .protection)
        #expect(HealthCheckStep.protection.next == nil)
    }
}
