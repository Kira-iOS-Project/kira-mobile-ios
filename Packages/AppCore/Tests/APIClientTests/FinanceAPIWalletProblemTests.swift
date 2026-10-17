import Domain
import Testing

@testable import APIClient

@Suite("Finance API wallet overview")
struct FinanceAPIWalletProblemTests {
    @Test("wallet overview preserves authentication failures and rejects undocumented statuses")
    func lists() async {
        await expectProblems([401]) { _ = try await $0.getWalletOverview() }
    }

    @Test("maps the API wallet and debt kinds to their app types")
    func walletTypes() throws {
        #expect(try walletType("cash") == .cash)
        #expect(try walletType("bank") == .bank)
        #expect(try walletType("ewallet") == .ewallet)
        #expect(try walletType("e_wallet") == .ewallet)
        #expect(try walletType("credit_card") == .creditCard)
        #expect(try walletType("paylater") == .paylater)
        #expect(try walletType("online_loan") == .onlineLoan)
        #expect(try walletType("pinjol") == .onlineLoan)
        #expect(try walletType("vehicle") == .vehicle)
        #expect(try walletType("mortgage") == .mortgage)
        #expect(try walletType("family_loan") == .familyLoan)
        #expect(try walletType("other") == .other)
        #expect(throws: AppProblem.self) { _ = try walletType("unknown") }
    }
}
