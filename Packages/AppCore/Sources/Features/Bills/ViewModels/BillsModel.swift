import APIClient
import Domain
import Foundation
import Observation

/**
 Tagihan & Cicilan (UNG-06, board Tagihan): the recurring bills in 7 Hari ke Depan, Bulan Ini and
 Bulan Depan, and each row's tag (lane AlurUang): days left, in turmeric when a bill is 5 days or
 fewer away or an instalment 10 or fewer; the due date for next month; paid this period in green.
 */
@MainActor
@Observable
package final class BillsModel {
    /** Loading, the bills (empty when there are none), or the failure. */
    package private(set) var phase: ScreenPhase<BillOverview> = .loading

    private let service: any BillService
    private let today: @Sendable () -> CalendarDay

    /** Bills from `service`, counted from `today` (WIB). */
    package init(service: any BillService, today: @escaping @Sendable () -> CalendarDay = { CalendarDay(Date()) }) {
        self.service = service
        self.today = today
    }

    /** Loads the bills; a failed reload keeps the bills on screen. */
    package func load() async {
        do {
            let overview = try await service.bills()
            phase = overview.sections.isEmpty ? .empty : .loaded(overview)
        } catch {
            if phase.value == nil { phase = .failed((error as? AppProblem) ?? AppProblem()) }
        }
    }

    /** The tag of `bill` in `group`. */
    package func tag(for bill: Bill, in group: BillGroup) -> BillTag {
        if bill.paidThisPeriod {
            let previous = bill.repeats == .yearly ? bill.nextDueOn : bill.nextDueOn.adding(months: -1)
            return .paid(month: previous.month)
        }
        if group == .nextMonth || group == .later { return .date(bill.nextDueOn) }
        let days = max(today().days(to: bill.nextDueOn), 0)
        let urgentWithin = bill.kind == .instalment ? 10 : 5
        return .daysLeft(days, urgent: days <= urgentWithin)
    }
}

/** A bill row's tag. */
package enum BillTag: Equatable, Sendable {
    /** "5 Hari Lagi", in turmeric when `urgent`. */
    case daysLeft(Int, urgent: Bool)
    /** "5 November 2026": due next month. */
    case date(CalendarDay)
    /** "Oktober Sudah Dibayar": this period's is paid; `month` 1 to 12. */
    case paid(month: Int)
}
