import APIClient
import Domain
import Foundation
import Observation

/**
 Detail Tujuan (REN-05): one goal's progress against its milestones (for the emergency fund: one
 week, one month, 3× and the target), the card for the milestone last reached, the next deposit
 and the deposits so far. "Tambah Setoran" opens a sheet whose submit goes to the server with an
 idempotency key, kept across Coba Lagi so a retry never deposits twice.
 */
@MainActor
@Observable
package final class GoalDetailModel {
    /** The goal the screen was opened for. */
    package let id: String
    /** The goal, loading until the API answers; empty when it no longer exists (GOAL_NOT_FOUND). */
    package private(set) var phase: ScreenPhase<GoalDetail> = .loading
    /** The deposit sheet: open, closed, or the problem of its last submit. */
    package var deposit = SheetSubmission()
    /** The amount typed in the sheet, in whole rupiah digits. */
    package var depositAmount = ""
    /** Whether the sheet's field says the amount is missing (a check the app makes itself). */
    package private(set) var isDepositAmountMissing = false
    /** Whether "Setoran Tersimpan" shows, after the server took the deposit. */
    package var showsDepositSaved = false

    @ObservationIgnored private let service: any GoalService
    @ObservationIgnored private let now: @Sendable () -> Date
    @ObservationIgnored private let makeId: @Sendable () -> String
    /** The idempotency key of the deposit being sent; the same across Coba Lagi. */
    @ObservationIgnored private var depositId = ""

    /** A model of goal `id`, loaded through `service`; the clock and the ids default to the system's. */
    package init(
        id: String, service: any GoalService, now: @escaping @Sendable () -> Date = { Date() },
        makeId: @escaping @Sendable () -> String = { UUID().uuidString }
    ) {
        self.id = id
        self.service = service
        self.now = now
        self.makeId = makeId
    }

    /** Loads the goal, or loads it again after a failure. */
    package func load() async {
        if phase.value == nil { phase = .loading }
        do {
            phase = .loaded(try await service.goal(id: id))
        } catch let problem as AppProblem where problem.knownCode == .goalNotFound {
            phase = .empty
        } catch {
            guard !Task.isCancelled else { return }
            if phase.value == nil { phase = .failed(AppProblem(error)) }
        }
    }

    /** How much of the target is saved, 0…1. */
    package var progress: Double {
        guard let goal = phase.value?.summary, goal.targetAmount > 0 else { return 0 }
        return min(max(Double(goal.savedAmount) / Double(goal.targetAmount), 0), 1)
    }

    /**
     The target in months of essential spending ("6×"): the target over the one-month milestone,
     which is the essential spending; nil for a goal without milestones.
     */
    package var targetMultiple: Double? {
        guard let goal = phase.value, let month = goal.milestones.first(where: { $0.key == .oneMonth }),
            month.amount > 0
        else { return nil }
        return Double(goal.summary.targetAmount) / Double(month.amount)
    }

    /** The first milestone not reached yet, and what is still missing to it. */
    package var nextMilestone: (milestone: GoalMilestone, shortfall: Int)? {
        guard let goal = phase.value, let next = goal.milestones.first(where: { $0.reachedOn == nil }) else {
            return nil
        }
        return (next, max(next.amount - goal.summary.savedAmount, 0))
    }

    /** The milestone reached last, which the celebration card names; nil before the first one. */
    package var latestReached: GoalMilestone? {
        phase.value?.milestones.last { $0.reachedOn != nil }
    }

    /**
     The next deposit, on the day of the month the last one was made ("Tiap Tanggal 25"): the next
     such day from today, in WIB; nil before the first deposit.
     */
    package var nextDeposit: (day: CalendarDay, dayOfMonth: Int)? {
        guard let last = phase.value?.deposits.first?.depositedOn else { return nil }
        let today = CalendarDay(now())
        let thisMonth = Self.day(last.day, ofMonth: today.month, in: today.year)
        guard thisMonth < today else { return (thisMonth, last.day) }
        return (Self.day(last.day, ofMonth: today.month % 12 + 1, in: today.year + today.month / 12), last.day)
    }

    /** Day `day` of a month, or its last day when the month is shorter (the 31st in February). */
    private static func day(_ day: Int, ofMonth month: Int, in year: Int) -> CalendarDay {
        CalendarDay(year: year, month: month, day: min(day, CalendarDay.length(ofMonth: month, in: year)))
    }

    /** "Tambah Setoran": the sheet opens on the goal's monthly deposit, with a new idempotency key. */
    package func openDeposit() {
        depositAmount = phase.value.map { String($0.summary.monthlyDeposit) } ?? ""
        isDepositAmountMissing = false
        depositId = makeId()
        deposit.open()
    }

    /**
     "Simpan" in the sheet, and again on Coba Lagi: an empty or zero amount stays inline; otherwise
     the deposit goes to the server, and the sheet closes on its answer.
     */
    package func submitDeposit() async {
        guard let amount = Int(depositAmount.filter(\.isNumber)), amount > 0 else {
            isDepositAmountMissing = true
            return
        }
        isDepositAmountMissing = false
        do {
            _ = try await service.addDeposit(
                goalId: id, amount: amount, depositedOn: CalendarDay(now()), depositId: depositId)
            deposit.close()
            showsDepositSaved = true
            await load()
        } catch {
            /** A key some other goal already used (GOAL_DEPOSIT_CONFLICT): Coba Lagi sends a new one. */
            if AppProblem(error).knownCode == .goalDepositConflict { depositId = makeId() }
            deposit.fail(error)
        }
    }
}
