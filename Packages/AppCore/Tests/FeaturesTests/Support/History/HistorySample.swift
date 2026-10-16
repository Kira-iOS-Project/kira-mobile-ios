import Domain
import Foundation

/** The canvas's sample: Riwayat on Thursday 15 October 2026, pay period 25 September – 24 October. */
enum HistorySample {
    static let today = CalendarDay(year: 2026, month: 10, day: 15)
    static let period = PayPeriod(
        start: CalendarDay(year: 2026, month: 9, day: 25), end: CalendarDay(year: 2026, month: 10, day: 24),
        daysUntilPayday: 10)
    /** 12.50 WIB on the sample's today. */
    static let now = today.start.addingTimeInterval(12 * 3600 + 50 * 60)

    static func at(_ day: CalendarDay, _ hour: Int, _ minute: Int) -> Date {
        day.start.addingTimeInterval(TimeInterval(hour * 3600 + minute * 60))
    }

    static let grab = Transaction(
        id: "grab", type: .expense, amount: 18_000, category: .transport, name: "Grab ke Kantor",
        occurredAt: at(today, 12, 41), source: .chat, sourceMessageId: "m-1241")

    static let transactions: [Transaction] = [
        grab,
        Transaction(
            id: "dinner", type: .expense, amount: 32_000, category: .food, name: "Makan Malam",
            occurredAt: at(today.adding(days: -1), 20, 10), source: .chat),
        Transaction(
            id: "parking", type: .expense, amount: 5_000, category: .transport, name: "Parkir",
            occurredAt: at(today.adding(days: -3), 18, 5), source: .chat),
        Transaction(
            id: "salary", type: .income, amount: 7_500_000, category: .salary, name: "Gaji",
            occurredAt: at(period.start, 9, 0), source: .manual),
    ]

    static let summary = TransactionSummary(
        expense: 5_660_000, income: 7_500_000,
        days: [DayTotals(day: today, expense: 78_000, income: 0)])

    static let detail = TransactionDetail(
        transaction: grab,
        sourceMessage: SourceQuote(
            id: "m-1241", body: "makan siang 25rb, grab ke kantor 18rb, kopi goceng", createdAt: at(today, 12, 41),
            spanStart: 18, spanEnd: 37))

    static let messages: [ChatMessage] = [
        ChatMessage(
            id: "m-0812", sender: .person, kind: .personText, body: "bensin 30rb", createdAt: at(today, 8, 12)),
        ChatMessage(
            id: "r-0812", sender: .kira, kind: .drafts, body: nil, createdAt: at(today, 8, 12), replyToId: "m-0812",
            draftStatus: .committed),
        ChatMessage(
            id: "m-1241", sender: .person, kind: .personText,
            body: "makan siang 25rb, grab ke kantor 18rb, kopi goceng",
            createdAt: at(today, 12, 41)),
        ChatMessage(
            id: "r-1241", sender: .kira, kind: .drafts, body: nil, createdAt: at(today, 12, 41), replyToId: "m-1241",
            draftStatus: .committed),
        ChatMessage(
            id: "left-1241", sender: .kira, kind: .remaining, body: nil, createdAt: at(today, 12, 42),
            remaining: 1_792_000,
            perDay: 179_200),
    ]

    static let preview = ImportPreview(
        id: "imp-1", dateFrom: CalendarDay(year: 2026, month: 9, day: 1),
        dateTo: CalendarDay(year: 2026, month: 9, day: 30),
        rows: [
            row("r1", "Bensin", 30_000, .transport, duplicate: true),
            row("r2", "Belanja Bulanan", 186_400, .shopping, duplicate: false),
            row("r3", "Internet Bulanan", 350_000, .bills, duplicate: false),
        ])

    static func row(_ id: String, _ name: String, _ amount: Int, _ category: TransactionCategory, duplicate: Bool)
        -> ImportPreviewRow
    {
        ImportPreviewRow(
            id: id, day: CalendarDay(year: 2026, month: 9, day: 27), description: name, amount: amount, type: .expense,
            category: category, isDuplicate: duplicate)
    }
}
