import Testing

@testable import APIClient

@Suite("Finance API wallet-list problems")
struct FinanceAPIWalletProblemTests {
    @Test("wallet and debt lists preserve authentication failures and reject undocumented statuses")
    func lists() async {
        await expectProblems([401]) { _ = try await $0.getWallets() }
        await expectProblems([401]) { _ = try await $0.getDebts() }
    }
}
