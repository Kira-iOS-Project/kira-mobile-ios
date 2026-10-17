import APIClient
import Domain
import Foundation
import Observation

/** UNG-08: loads one completed Thursday-to-Wednesday summary without inventing data for an empty week. */
@MainActor
@Observable
package final class WeeklySummaryModel {
    /** The weekday underneath one chart bar. */
    package enum Weekday: Hashable, Sendable {
        /** Sunday. */
        case sunday
        /** Monday. */
        case monday
        /** Tuesday. */
        case tuesday
        /** Wednesday. */
        case wednesday
        /** Thursday. */
        case thursday
        /** Friday. */
        case friday
        /** Saturday. */
        case saturday
    }

    /** A day's expense bar with its localized weekday key chosen by the model. */
    package struct ChartDay: Hashable, Sendable, Identifiable {
        /** Stable order from Thursday through Wednesday. */
        package let index: Int
        /** The weekday label. */
        package let weekday: Weekday
        /** Expense amount for the day. */
        package let expense: Int
        /** The bar's stable identity. */
        package var id: Int { index }

        package init(index: Int, weekday: Weekday, expense: Int) {
            self.index = index
            self.weekday = weekday
            self.expense = expense
        }
    }

    /** The week's loading, empty, data or failure phase. */
    package private(set) var phase: ScreenPhase<WeeklySummary> = .loading

    /** The seven weekday labels and amounts, in server order. */
    package var chartDays: [ChartDay] {
        chartDays(wibOffset: CalendarDay.wibOffset)
    }

    /** Maps each calendar day with the given offset, including the GMT fallback for an invalid zone. */
    package func chartDays(wibOffset: Int) -> [ChartDay] {
        guard let summary = phase.value else { return [] }
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: wibOffset) ?? .gmt
        return summary.days.enumerated().map { index, day in
            let raw = calendar.component(.weekday, from: day.date.date)
            let weekday: Weekday
            switch raw {
            case 1: weekday = .sunday
            case 2: weekday = .monday
            case 3: weekday = .tuesday
            case 4: weekday = .wednesday
            case 5: weekday = .thursday
            case 6: weekday = .friday
            default: weekday = .saturday
            }
            return ChartDay(index: index, weekday: weekday, expense: day.expense)
        }
    }

    /** The highest-spending day gets the highlighted chart bar; ties keep the first day. */
    package var highlightedChartIndex: Int? {
        chartDays.max { $0.expense < $1.expense }?.index
    }

    private let service: any WeeklySummaryService
    private let today: @Sendable () -> CalendarDay

    /** The weekly screen, with an injectable WIB day. */
    package init(
        service: any WeeklySummaryService, today: @escaping @Sendable () -> CalendarDay = { CalendarDay(Date()) }
    ) {
        self.service = service
        self.today = today
    }

    /** Loads the latest completed week, whose last day is Wednesday. */
    package func load() async {
        if phase.value == nil { phase = .loading }
        let weekStart = WeeklySummary.latestCompletedWeekStart(on: today())
        do {
            let summary = try await service.weeklySummary(weekStart: weekStart)
            phase = summary.isEmpty ? .empty : .loaded(summary)
        } catch {
            phase = .failed(weeklySummaryProblem(error))
        }
    }
}
