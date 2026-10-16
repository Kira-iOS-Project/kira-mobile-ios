/**
 The canvas's sample for the history flow (boards Riwayat, DetailTransaksi, RiwayatPercakapan and
 TinjauImpor): Dinda on Thursday 15 October 2026, pay period 25 September – 24 October, Rp5.660.000,00
 out and Rp7.500.000,00 in. Previews and the app before integration read it through
 PreviewHistoryService.
 */
import Domain
import Foundation

nonisolated enum PreviewHistoryData {
    static let today = CalendarDay(year: 2026, month: 10, day: 15)
    static let period = PayPeriod(
        start: CalendarDay(year: 2026, month: 9, day: 25), end: CalendarDay(year: 2026, month: 10, day: 24),
        daysUntilPayday: 10)
    // periphery:ignore - HistoryScreen's #Preview, which the scan does not follow
    /** 12.50 WIB on the sample's Thursday. */
    static let now = at(today, 12, 50)

    static func at(_ day: CalendarDay, _ hour: Int, _ minute: Int) -> Date {
        day.start.addingTimeInterval(TimeInterval(hour * 3600 + minute * 60))
    }

    private static func day(_ month: Int, _ day: Int) -> CalendarDay {
        CalendarDay(year: 2026, month: month, day: day)
    }

    private static func spend(
        _ id: String, _ name: String, _ amount: Int, _ category: TransactionCategory, _ date: Date,
        _ source: TransactionSource = .chat, message: String? = nil
    ) -> Transaction {
        Transaction(
            id: id, type: .expense, amount: amount, category: category, name: name, occurredAt: date,
            source: source, sourceMessageId: message)
    }

    /** Newest first, as the API lists them. */
    static let transactions: [Transaction] = [
        spend("coffee", "Kopi", 5_000, .coffee, at(today, 12, 41), message: "m-1241"),
        spend("grab", "Grab ke Kantor", 18_000, .transport, at(today, 12, 41), message: "m-1241"),
        spend("lunch", "Makan Siang", 25_000, .food, at(today, 12, 41), message: "m-1241"),
        spend("fuel", "Bensin", 30_000, .transport, at(today, 8, 12), message: "m-0812"),
        spend("dinner", "Makan Malam", 32_000, .food, at(day(10, 14), 20, 10)),
        spend("groceries", "Belanja Mingguan", 45_000, .shopping, at(day(10, 14), 19, 20), .manual),
        spend("parking", "Parkir", 5_000, .transport, at(day(10, 14), 18, 5)),
        spend("bpjs", "BPJS Kesehatan", 120_000, .health, at(day(10, 10), 9, 0), .manual),
        spend("paylater", "Cicilan Paylater", 1_250_000, .paylaterInstalment, at(day(10, 5), 10, 0), .manual),
        spend("rent", "Sewa Kos", 2_500_000, .household, at(day(10, 1), 8, 0), .manual),
        spend("internet", "Internet Bulanan", 350_000, .bills, at(day(9, 30), 7, 0), .bankImport),
        spend("power", "Token Listrik", 300_000, .bills, at(day(9, 28), 19, 0), .bankImport),
        spend("monthly", "Belanja Bulanan", 980_000, .shopping, at(day(9, 27), 16, 30), .receipt),
        Transaction(
            id: "salary", type: .income, amount: 7_500_000, category: .salary, name: "Gaji",
            occurredAt: at(period.start, 9, 0), source: .manual),
    ]

    static let lunchMessage = "makan siang 25rb, grab ke kantor 18rb, kopi goceng"

    /** Where a chat transaction sits in its message, in UTF-16 units. */
    struct Span {
        let message: String
        let sentAt: Date
        let start: Int
        let end: Int
    }

    /** The span of each chat transaction. */
    static let spans: [String: Span] = [
        "lunch": Span(message: lunchMessage, sentAt: at(today, 12, 41), start: 0, end: 16),
        "grab": Span(message: lunchMessage, sentAt: at(today, 12, 41), start: 18, end: 37),
        "coffee": Span(message: lunchMessage, sentAt: at(today, 12, 41), start: 39, end: 50),
        "fuel": Span(message: "bensin 30rb", sentAt: at(today, 8, 12), start: 0, end: 11),
    ]

    static let messages: [ChatMessage] = [
        ChatMessage(
            id: "m-0812", sender: .person, kind: .personText, body: "bensin 30rb", createdAt: at(today, 8, 12)),
        ChatMessage(
            id: "r-0812", sender: .kira, kind: .drafts, body: nil, createdAt: at(today, 8, 12), replyToId: "m-0812",
            drafts: [draft("d1", "Bensin", 30_000, .transport)], draftStatus: .committed),
        ChatMessage(
            id: "m-1241", sender: .person, kind: .personText, body: lunchMessage, createdAt: at(today, 12, 41)),
        ChatMessage(
            id: "r-1241", sender: .kira, kind: .drafts, body: nil, createdAt: at(today, 12, 41), replyToId: "m-1241",
            drafts: [
                draft("d2", "Makan Siang", 25_000, .food), draft("d3", "Grab ke Kantor", 18_000, .transport),
                draft("d4", "Kopi", 5_000, .coffee),
            ],
            draftStatus: .committed),
        ChatMessage(
            id: "left-1241", sender: .kira, kind: .remaining, body: nil, createdAt: at(today, 12, 41),
            remaining: 1_792_000, perDay: 179_200),
    ]

    private static func draft(_ id: String, _ name: String, _ amount: Int, _ category: TransactionCategory)
        -> DraftItem
    {
        DraftItem(id: id, type: .expense, name: name, amount: amount, category: category, occurredAt: at(today, 12, 41))
    }
}
