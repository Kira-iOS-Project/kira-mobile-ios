import Foundation
import Testing

@testable import Domain

@Suite("HistoryTimeline")
struct HistoryTimelineTests {
    private let period = PayPeriod(
        start: CalendarDay(year: 2026, month: 9, day: 25), end: CalendarDay(year: 2026, month: 10, day: 24))
    private let today = CalendarDay(year: 2026, month: 10, day: 15)

    private func spend(_ id: String, on day: CalendarDay, hour: Int) -> Transaction {
        Transaction(
            id: id, type: .expense, amount: 1_000, category: .food, name: id,
            occurredAt: day.start.addingTimeInterval(TimeInterval(hour * 3600)), source: .chat)
    }

    private var summary: TransactionSummary {
        TransactionSummary(
            expense: 160_000, income: 7_500_000,
            days: [DayTotals(day: today, expense: 78_000, income: 0)])
    }

    @Test("groups by day, newest first, newest transaction first, with each day's totals and kind")
    func days() {
        let transactions = [
            spend("pagi", on: today, hour: 8), spend("siang", on: today, hour: 12),
            spend("kemarin", on: today.adding(days: -1), hour: 20), spend("gaji", on: period.start, hour: 9),
        ]
        let days = HistoryTimeline.days(transactions, summary: summary, period: period, today: today)
        #expect(days.map(\.day) == [today, today.adding(days: -1), period.start])
        #expect(days.map(\.kind) == [.today, .past, .payday])
        #expect(days[0].transactions.map(\.id) == ["siang", "pagi"])
        #expect(days[0].totals.expense == 78_000)
        #expect(days[1].totals.expense == 0)
        #expect(days[0].id == today)
    }

    @Test("folds the days between the two newest and payday")
    func folded() {
        let days = dayList([0, -1, -3, -10], payday: true)
        let sections = HistoryTimeline.sections(days, period: period, isExpanded: false)
        #expect(
            sections == [
                .day(days[0]), .day(days[1]),
                .olderDays(from: period.start.adding(days: 1), to: today.adding(days: -2)),
                .day(days[4]),
            ])
        #expect(sections[2].id == "older-2026-09-26")
        #expect(sections[0].id == "day-2026-10-15")
    }

    @Test("folds from payday itself when payday has no transaction loaded")
    func foldedWithoutPayday() {
        let days = dayList([0, -1, -3], payday: false)
        let sections = HistoryTimeline.sections(days, period: period, isExpanded: false)
        #expect(sections.last == .olderDays(from: period.start, to: today.adding(days: -2)))
    }

    @Test("shows every day when opened, or when nothing would fold")
    func unfolded() {
        let days = dayList([0, -1, -3], payday: true)
        #expect(HistoryTimeline.sections(days, period: period, isExpanded: true) == days.map(HistorySection.day))
        let short = dayList([0, -1], payday: true)
        #expect(HistoryTimeline.sections(short, period: period, isExpanded: false) == short.map(HistorySection.day))
    }

    private func dayList(_ offsets: [Int], payday: Bool) -> [HistoryDay] {
        var transactions = offsets.map { spend("d\($0)", on: today.adding(days: $0), hour: 10) }
        if payday { transactions.append(spend("gaji", on: period.start, hour: 9)) }
        return HistoryTimeline.days(transactions, summary: summary, period: period, today: today)
    }
}

@Suite("ConversationMessage")
struct ConversationMessageTests {
    @Test("reads the API's words and defaults the reply fields to empty")
    func defaults() {
        let message = ConversationMessage(
            id: "m1", sender: .person, kind: .personText, body: "bensin 30rb", createdAt: .distantPast)
        #expect(message.drafts.isEmpty && message.replyToId == nil && message.draftStatus == nil)
        #expect(message.remaining == nil && message.perDay == nil)
        #expect(ConversationMessage.Kind(rawValue: "no_drafts") == .noDrafts)
        #expect(ConversationMessage.Draft(id: "d1", name: "Bensin", amount: 30_000, category: .transport).amount == 30_000)
    }
}
