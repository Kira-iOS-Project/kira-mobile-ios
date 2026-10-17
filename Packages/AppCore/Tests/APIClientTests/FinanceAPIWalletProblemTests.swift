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
        #expect(try walletType(WalletType.onlineLoan.rawValue) == .onlineLoan)
        #expect(try walletType("vehicle") == .vehicle)
        #expect(try walletType("mortgage") == .mortgage)
        #expect(try walletType("family_loan") == .familyLoan)
        #expect(try walletType("other") == .other)
        #expect(throws: AppProblem.self) { _ = try walletType("unknown") }
    }

    @Test("wallet creation preserves authentication and validation problems")
    func createWalletProblems() async {
        await expectProblems([401, 422]) {
            _ = try await $0.createWallet(type: .cash, name: "Tunai", balance: 100)
        }
        await expectProblems([401, 422]) {
            _ = try await $0.createWallet(type: .paylater, name: "Paylater", balance: 100)
        }
    }

    @Test("maps each selectable account type to its public create-wallet payload")
    func createWalletTypes() throws {
        for type in WalletType.selectableCases {
            let input = try createWalletInput(type: type, name: "Akun", balance: 500)
            if let wallet = input.value1 {
                #expect(wallet.name == "Akun" && wallet.balance == 500 && !type.isDebt)
            } else if let debt = input.value2 {
                #expect(debt.name == "Akun" && debt.remainingDebt == 500 && type.isDebt)
            } else {
                Issue.record("selectable wallet type should create one account payload")
            }
        }
        #expect(try createWalletInput(type: .ewallet, name: "A", balance: 1).value1?._type == .eWallet)
        #expect(try createWalletInput(type: .other, name: "A", balance: 1).value1?._type == .other)
        #expect(
            try createWalletInput(type: .onlineLoan, name: "A", balance: 1).value2?._type.rawValue
                == WalletType.onlineLoan.rawValue)
        #expect(try createWalletInput(type: .creditCard, name: "A", balance: 1).value2?._type == .creditCard)
        #expect(try createWalletInput(type: .paylater, name: "A", balance: 1).value2?._type == .paylater)
        #expect(throws: AppProblem.self) {
            _ = try createWalletInput(type: .vehicle, name: "A", balance: 1)
        }
    }

    @Test("rejects a create response without either account shape")
    func emptyCreatedWallet() {
        let response = Operations.CreateWallet.Output.created(.init(body: .json(.init())))
        #expect(throws: AppProblem.self) { _ = try response.wallet() }
    }
}
