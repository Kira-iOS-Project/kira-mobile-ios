import APIClient
import Domain
import Foundation
import Testing

@testable import Features

@Suite("WalletsModel")
@MainActor
struct WalletsModelTests {
    @Test("loads held wallets and debts together and toggles every amount")
    func loadAndMask() async {
        let held = Wallet(id: "bank", name: "Bank", type: .bank, balance: 7_402_000)
        let debt = Wallet(id: "debt", name: "Paylater", type: .paylater, balance: 420_000)
        let model = WalletsModel(service: FakeWalletService(wallets: [held], debts: [debt]))
        await model.load()
        guard case .loaded(let overview) = model.phase else {
            Issue.record("Expected loaded accounts")
            return
        }
        #expect(overview.heldTotal == 7_402_000)
        #expect(overview.runningDebt == 420_000)
        #expect(model.hidesBalances == false)
        model.toggleBalances()
        #expect(model.hidesBalances)
        model.toggleBalances()
        #expect(model.hidesBalances == false)
    }

    @Test("empty and failed loads use their matching phase")
    func emptyAndFailure() async {
        let empty = WalletsModel(service: FakeWalletService())
        await empty.load()
        if case .empty = empty.phase {} else { Issue.record("Expected empty accounts") }

        let broken = FakeWalletService()
        await broken.configure(failures: [.overview])
        let failed = WalletsModel(service: broken)
        await failed.load()
        guard case .failed(let problem) = failed.phase else {
            Issue.record("Expected failed accounts")
            return
        }
        #expect(problem.code == "ROUTE_NOT_FOUND")
        #expect(walletProblem(problem) == problem)
        #expect(walletProblem(WalletTestError()) == AppProblem())

        let bank = Wallet(id: "bank", name: "Bank", type: .bank, balance: 100)
        let service = FakeWalletService(wallets: [bank])
        let refreshing = WalletsModel(service: service)
        await refreshing.load()
        await service.configure(failures: [.overview])
        await refreshing.load()
        #expect(refreshing.phase.value?.wallets == [bank])
    }

    @Test("due-soon includes today and day ten but excludes past, day eleven, and missing dates")
    func dueSoonWindow() {
        let now = Date(timeIntervalSince1970: 1_800_000_000)
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .gmt
        let model = WalletsModel(service: FakeWalletService(), now: { now }, calendar: calendar)
        #expect(model.isDueSoon(wallet("today", due: now)))
        #expect(model.isDueSoon(wallet("ten", due: now.addingTimeInterval(10 * 86_400))))
        #expect(model.isDueSoon(wallet("past", due: now.addingTimeInterval(-86_400))) == false)
        #expect(model.isDueSoon(wallet("eleven", due: now.addingTimeInterval(11 * 86_400))) == false)
        #expect(model.isDueSoon(wallet("none", due: nil)) == false)
        #expect(model.isDueSoon(wallet("today", due: now), within: -1) == false)
        #expect(model.isDueSoon(wallet("server-false", due: now, dueSoon: false)))
        #expect(model.isDueSoon(wallet("server-true", due: nil, dueSoon: true)))
        #expect(model.isDueSoon(Wallet(id: "cash", name: "Cash", type: .cash, balance: 1, dueSoon: true)) == false)
    }

    @Test("uses the Jakarta calendar and device clock by default")
    func defaultClockAndCalendar() {
        let model = WalletsModel(service: FakeWalletService())
        #expect(model.isDueSoon(wallet("tomorrow", due: Date().addingTimeInterval(86_400))))
    }

    @Test("a newly saved account is added, highlights its row, and updates held totals")
    func addedWallet() async {
        let existing = Wallet(id: "bank", name: "Bank", type: .bank, balance: 100)
        let model = WalletsModel(service: FakeWalletService(wallets: [existing]))
        await model.load()
        let added = Wallet(id: "cash", name: "Tunai", type: .cash, balance: 50)
        model.walletAdded(added)
        #expect(model.highlightedWalletID == "cash")
        #expect(model.phase.value?.wallets == [existing, added])
        #expect(model.phase.value?.heldTotal == 150)

        model.walletAdded(existing)
        #expect(model.phase.value?.wallets == [added, existing])

        let empty = WalletsModel(service: FakeWalletService())
        empty.walletAdded(added)
        #expect(empty.phase.value?.accounts == [added])
    }

    @Test("applies a recorded payment to the matching debt row")
    func debtUpdated() async {
        let bank = Wallet(id: "bank", name: "Bank", type: .bank, balance: 100)
        let debt = Wallet(id: "debt", name: "Paylater", type: .paylater, balance: 420)
        let model = WalletsModel(service: FakeWalletService(wallets: [bank], debts: [debt]))
        let updatedDetail = DebtDetail(
            account: Wallet(id: "debt", name: "Paylater", type: .paylater, balance: 300),
            originalAmount: 420, paidInstallments: 1, totalInstallments: 4,
            schedule: [], payments: [], scoreEstimate: DebtScoreEstimate(current: 66, afterPayoff: 71))
        model.debtUpdated(updatedDetail)
        #expect(model.phase.value == nil)

        await model.load()
        model.debtUpdated(updatedDetail)
        #expect(model.phase.value?.runningDebt == 300)
        #expect(model.phase.value?.heldTotal == 100)
        #expect(model.phase.value?.accounts.map(\.id) == ["bank", "debt"])
    }

    private func wallet(_ id: String, due: Date?, dueSoon: Bool = false) -> Wallet {
        Wallet(id: id, name: id, type: .paylater, balance: 1, nextDueAt: due, dueSoon: dueSoon)
    }
}

private struct WalletTestError: Error {}
