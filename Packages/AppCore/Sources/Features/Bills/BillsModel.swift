import Domain
import Foundation
import Observation

/** A chronological group in Tagihan & Cicilan. */
package struct BillSection: Hashable, Sendable, Identifiable {
    /** The heading chosen by the screen. */
    package enum Kind: String, Hashable, Sendable, CaseIterable {
        /** Due now or during the next seven days. */
        case nextSevenDays
        /** Later this month. */
        case thisMonth
        /** During the following calendar month. */
        case nextMonth
        /** Later than next month. */
        case later
    }

    /** The stable section kind. */
    package var id: Kind { kind }
    /** Its heading. */
    package let kind: Kind
    /** The schedules sorted by due date then name. */
    package let bills: [RecurringBill]

    /** A visible group of due schedules. */
    package init(kind: Kind, bills: [RecurringBill]) {
        self.kind = kind
        self.bills = bills
    }
}

/** The ordered schedules and nonempty sections the list shows. */
package struct BillsContent: Hashable, Sendable {
    /** The source rows, earliest due first. */
    package let bills: [RecurringBill]
    /** Only the sections that have rows. */
    package let sections: [BillSection]

    /** Groups bill dates relative to the current WIB day. */
    package init(bills: [RecurringBill], today: CalendarDay) {
        let ordered = bills.sorted {
            $0.nextDueDate == $1.nextDueDate ? $0.name < $1.name : $0.nextDueDate < $1.nextDueDate
        }
        let firstOfMonth = CalendarDay(year: today.year, month: today.month, day: 1)
        let endOfThisMonth = firstOfMonth.adding(months: 1).adding(days: -1)
        let endOfNextMonth = firstOfMonth.adding(months: 2).adding(days: -1)
        let cutOff = today.adding(days: 7)
        self.bills = ordered
        sections = BillSection.Kind.allCases.compactMap { kind in
            let rows = ordered.filter { bill in
                switch kind {
                case .nextSevenDays: bill.nextDueDate <= cutOff
                case .thisMonth: bill.nextDueDate > cutOff && bill.nextDueDate <= endOfThisMonth
                case .nextMonth: bill.nextDueDate > endOfThisMonth && bill.nextDueDate <= endOfNextMonth
                case .later: bill.nextDueDate > endOfNextMonth
                }
            }
            return rows.isEmpty ? nil : BillSection(kind: kind, bills: rows)
        }
    }
}

/** UNG-06 Tagihan & Cicilan: sorts and groups schedules, leaving flags to the server's engine. */
@MainActor
@Observable
package final class BillsModel {
    /** The phase the list draws. */
    package private(set) var phase: ScreenPhase<BillsContent> = .loading
    private let service: any BillsService
    private let today: @Sendable () -> CalendarDay

    /** The list, with an injectable WIB day for grouping tests. */
    package init(service: any BillsService, today: @escaping @Sendable () -> CalendarDay = { CalendarDay(Date()) }) {
        self.service = service
        self.today = today
    }

    /** Loads schedules and splits the upcoming seven days, the rest of this month and later months. */
    package func load() async {
        if phase.value == nil { phase = .loading }
        do {
            let bills = try await service.bills()
            guard !bills.isEmpty else {
                phase = .empty
                return
            }
            phase = .loaded(BillsContent(bills: bills, today: today()))
        } catch {
            phase = .failed(billsProblem(error))
        }
    }

}
