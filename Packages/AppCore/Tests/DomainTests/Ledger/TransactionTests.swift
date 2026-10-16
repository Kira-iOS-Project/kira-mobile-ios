import Foundation
import Testing

@testable import Domain

@Suite("Transaction")
struct TransactionTests {
    private let october15 = CalendarDay(year: 2026, month: 10, day: 15)

    private func grab(note: String? = nil) -> Transaction {
        Transaction(
            id: "t1", type: .expense, amount: 18_000, category: .transport, name: "Grab ke Kantor",
            occurredAt: october15.start.addingTimeInterval(12 * 3600 + 41 * 60), note: note, source: .chat,
            sourceMessageId: "m1")
    }

    @Test("falls on its WIB day")
    func day() {
        let lateNight = Transaction(
            id: "t2", type: .income, amount: 1, category: .salary, name: "Gaji",
            occurredAt: october15.start.addingTimeInterval(-60), source: .manual)
        #expect(grab().day == october15)
        #expect(lateNight.day == CalendarDay(year: 2026, month: 10, day: 14))
        #expect(lateNight.note == nil && lateNight.sourceMessageId == nil)
    }

    @Test("reads the API's source names", arguments: [("chat", TransactionSource.chat), ("bank_import", .bankImport)])
    func source(raw: String, source: TransactionSource) {
        #expect(TransactionSource(rawValue: raw) == source)
    }

    @Test("cuts the source message around the span")
    func quoteParts() {
        let quote = quote("makan siang 25rb, grab ke kantor 18rb, kopi goceng", 18, 37)
        #expect(
            quote.parts
                == QuoteParts(before: "makan siang 25rb, ", highlight: "grab ke kantor 18rb", after: ", kopi goceng"))
    }

    @Test("counts the span in UTF-16 units and widens it to whole characters")
    func quoteUnits() {
        #expect(quote("🍜 makan 25rb", 3, 8).parts == QuoteParts(before: "🍜 ", highlight: "makan", after: " 25rb"))
        #expect(quote("a🍜b", 2, 4).parts == QuoteParts(before: "a", highlight: "🍜b", after: ""))
    }

    @Test(
        "highlights nothing for a missing or broken span",
        arguments: [(nil, 3), (0, nil), (-1, 2), (3, 3), (4, 2), (0, 99)] as [(Int?, Int?)])
    func brokenSpan(start: Int?, end: Int?) {
        #expect(quote("kopi goceng", start, end).parts == QuoteParts(before: "kopi goceng", highlight: "", after: ""))
    }

    @Test("keeps the source message when the transaction is replaced")
    func replacing() {
        let detail = TransactionDetail(transaction: grab(), sourceMessage: quote("grab 18rb", 0, 9))
        let edited = detail.replacing(grab(note: "kantor"))
        #expect(edited.transaction.note == "kantor")
        #expect(edited.sourceMessage == detail.sourceMessage)
    }

    private func quote(_ body: String, _ start: Int?, _ end: Int?) -> SourceQuote {
        SourceQuote(id: "m1", body: body, createdAt: october15.start, spanStart: start, spanEnd: end)
    }
}

@Suite("TransactionChange")
struct TransactionChangeTests {
    private let original = Transaction(
        id: "t1", type: .expense, amount: 18_000, category: .transport, name: "Grab ke Kantor",
        occurredAt: Date(timeIntervalSince1970: 0), note: nil, source: .chat, sourceMessageId: "m1")

    @Test("is empty until a field changes")
    func empty() {
        #expect(TransactionChange().isEmpty)
        #expect(!TransactionChange(name: "Grab").isEmpty)
        #expect(!TransactionChange(amount: 1).isEmpty)
        #expect(!TransactionChange(category: .food).isEmpty)
        #expect(!TransactionChange(occurredAt: .distantPast).isEmpty)
        #expect(!TransactionChange(note: "x").isEmpty)
    }

    @Test("applies the changed fields and keeps the rest")
    func applied() {
        let moved = Date(timeIntervalSince1970: 60)
        let change = TransactionChange(name: "Grab", amount: 20_000, category: .food, occurredAt: moved, note: "pagi")
        let edited = change.applied(to: original)
        #expect(edited.name == "Grab" && edited.amount == 20_000 && edited.category == .food)
        #expect(edited.occurredAt == moved && edited.note == "pagi")
        #expect(edited.id == original.id && edited.source == .chat && edited.sourceMessageId == "m1")
        #expect(TransactionChange().applied(to: original) == original)
    }
}

@Suite("TransactionSummary")
struct TransactionSummaryTests {
    @Test("gives a listed day's totals, and zero for a day it does not list")
    func totals() {
        let day = CalendarDay(year: 2026, month: 10, day: 15)
        let summary = TransactionSummary(
            expense: 78_000, income: 0, days: [DayTotals(day: day, expense: 78_000, income: 0)])
        #expect(summary.totals(on: day).expense == 78_000)
        #expect(summary.totals(on: day.adding(days: -1)) == DayTotals(day: day.adding(days: -1), expense: 0, income: 0))
        let query = TransactionQuery(start: day, end: day, limit: 50)
        #expect(query.type == nil && query.category == nil && query.text == nil && query.cursor == nil)
        #expect(TransactionPage(items: [], nextCursor: nil).items.isEmpty)
        #expect(PayPeriod(start: day, end: day, daysUntilPayday: 1).nextPayday == day.adding(days: 1))
    }
}
