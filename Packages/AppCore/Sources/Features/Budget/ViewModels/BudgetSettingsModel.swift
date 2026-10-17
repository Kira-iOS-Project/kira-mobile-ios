import APIClient
import Domain
import Foundation
import Observation

/**
 Atur Budget (UNG-05, KIR-39): the payday (its picker, UNG-05d, moves the period with it), each
 category's amount beside its three-period average, the Dana Darurat deposit Rencana sets, and the
 share of the income that is allocated. "Simpan Budget" saves the payday and the amounts; Budget
 Tersimpan (UNG-05b) or, on a failure, Belum Berhasil Menyimpan (UNG-05c) with the numbers kept.
 */
@MainActor @Observable
package final class BudgetSettingsModel {
    /** Loading, loaded, or failed with the problem and Coba Lagi. */
    package private(set) var phase = ScreenPhase<BudgetSetup>.loading
    /** The payday, as the picker last left it. */
    package var payday = Payday(day: Payday.defaultDay)
    /** Each category's amount as typed, grouped. */
    package var amounts: [TransactionCategory: String] = [:]
    /** Whether "Simpan Budget" is on its way. */
    package private(set) var isSaving = false
    /** Budget Tersimpan is showing. */
    package var showsSaved = false
    /** The last save's problem, for Belum Berhasil Menyimpan; nil once it is closed. */
    package var failure: AppProblem?
    private let service: any BudgetSettingsService
    private let today: @Sendable () -> CalendarDay

    /** Atur Budget through `service`, its period counted from `today`. */
    package init(
        service: any BudgetSettingsService, today: @escaping @Sendable () -> CalendarDay = { CalendarDay(Date()) }
    ) {
        self.service = service
        self.today = today
    }

    /** Loads the setup, or again after a failure. */
    package func load() async {
        do {
            let setup = try await service.budgetSetup()
            payday = setup.payday
            amounts = Dictionary(
                uniqueKeysWithValues: setup.categories.map {
                    ($0, AmountInput.text(for: setup.allocations[$0]))
                })
            phase = .loaded(setup)
        } catch is CancellationError {
            return
        } catch {
            phase = .failed(AppProblem(error))
        }
    }

    /** The period the payday gives today ("25 September – 24 Oktober 2026"). */
    package var period: PayPeriod { payday.period(containing: today()) }

    /** "Teralokasi": every category's amount plus the Dana Darurat deposit. */
    package var allocated: Int {
        amounts.values.reduce(0) { $0 + (AmountInput.value(of: $1) ?? 0) } + (phase.value?.goalDeposit ?? 0)
    }

    /** "Belum dialokasikan": the income less what is allocated, never below zero. */
    package var unallocated: Int { max((phase.value?.income ?? 0) - allocated, 0) }

    /** Simpan Budget: saves, then Budget Tersimpan; a failure keeps the numbers for Coba Lagi. */
    package func save() async {
        guard let setup = phase.value, !isSaving else { return }
        isSaving = true
        defer { isSaving = false }
        let plan = BudgetPlan(
            payday: payday,
            allocations: Dictionary(
                uniqueKeysWithValues: setup.categories.map {
                    ($0, AmountInput.value(of: amounts[$0] ?? "") ?? 0)
                }))
        do {
            try await service.saveBudget(plan)
            showsSaved = true
        } catch is CancellationError {
            return
        } catch {
            failure = AppProblem(error)
        }
    }
}
