import APIClient
import Domain
import Foundation
import Testing

@testable import Features

/** Atur Budget's service for tests: the board's setup, saves recorded, failures on demand. */
private actor FakeBudgetSettingsService: BudgetSettingsService {
    var failures: [any Error]
    var setupFailure: (any Error)?
    private(set) var saved: [BudgetPlan] = []

    init(failures: [any Error] = [], setupFailure: (any Error)? = nil) {
        self.failures = failures
        self.setupFailure = setupFailure
    }

    func budgetSetup() throws -> BudgetSetup {
        if let setupFailure { throw setupFailure }
        return BudgetSetup(
            income: 7_500_000, payday: Payday(day: 25),
            allocations: [
                .food: 1_800_000, .transport: 900_000, .shopping: 600_000, .entertainment: 400_000,
                .bills: 850_000,
            ],
            averages: [.food: 1_720_000], instalments: 1_350_000, goalDeposit: 650_000)
    }

    func saveBudget(_ plan: BudgetPlan) throws {
        if !failures.isEmpty { throw failures.removeFirst() }
        saved.append(plan)
    }
}

@MainActor
@Suite("BudgetSettingsModel")
struct BudgetSettingsModelTests {
    private func model(_ service: FakeBudgetSettingsService) -> BudgetSettingsModel {
        BudgetSettingsModel(service: service, today: { CalendarDay(year: 2026, month: 10, day: 17) })
    }

    @Test("loads the board: Rp5.200.000,00 allocated of Rp7.500.000,00, the period from the payday")
    func board() async {
        let model = model(FakeBudgetSettingsService())
        await model.load()
        #expect(model.amounts[.food] == "1.800.000" && model.allocated == 5_200_000 && model.unallocated == 2_300_000)
        #expect(model.period.start == CalendarDay(year: 2026, month: 9, day: 25))
        model.payday = .endOfMonth
        #expect(model.period.start == CalendarDay(year: 2026, month: 9, day: 30))
    }

    @Test("Simpan Budget sends the payday and every category, typed or empty, then Budget Tersimpan")
    func save() async throws {
        let service = FakeBudgetSettingsService()
        let model = model(service)
        await model.save()
        await model.load()
        model.amounts[.food] = "2.000.000"
        model.amounts[.bills] = ""
        await model.save()
        let plan = try #require(await service.saved.first)
        #expect(plan.allocations[.food] == 2_000_000 && plan.allocations[.bills] == 0 && plan.payday == Payday(day: 25))
        #expect(model.showsSaved && model.failure == nil && !model.isSaving)
    }

    @Test("a failed save keeps the numbers and shows its problem; a cancelled one shows nothing")
    func failures() async {
        let model = model(
            FakeBudgetSettingsService(failures: [URLError(.notConnectedToInternet), CancellationError()]))
        await model.load()
        model.amounts[.food] = "1.000.000"
        await model.save()
        #expect(model.failure == .connectionLost && model.amounts[.food] == "1.000.000" && !model.showsSaved)
        model.failure = nil
        await model.save()
        #expect(model.failure == nil && !model.showsSaved)
    }

    @Test("a setup that fails to load shows its problem; a cancelled load changes nothing; over-allocation stops at 0")
    func load() async {
        let failing = model(FakeBudgetSettingsService(setupFailure: URLError(.timedOut)))
        await failing.load()
        #expect(failing.phase.problem == .connectionLost && failing.unallocated == 0)
        let cancelled = model(FakeBudgetSettingsService(setupFailure: CancellationError()))
        await cancelled.load()
        #expect(cancelled.phase.value == nil && cancelled.phase.problem == nil)
        let full = model(FakeBudgetSettingsService())
        await full.load()
        full.amounts[.food] = "9.000.000"
        #expect(full.unallocated == 0)
    }

    @Test("an empty amount counts as nothing; a category missing from the form is saved as 0; today is the clock's")
    func gaps() async throws {
        let service = FakeBudgetSettingsService()
        let model = BudgetSettingsModel(service: service)
        await model.load()
        model.amounts[.food] = ""
        #expect(model.allocated == 3_400_000)
        model.amounts[.transport] = nil
        await model.save()
        #expect(try #require(await service.saved.first).allocations[.transport] == 0)
        #expect(model.period.start < model.period.end)
    }
}
