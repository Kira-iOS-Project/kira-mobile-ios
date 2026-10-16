/** LiveHistoryService over a canned transport: each call's request and its Domain values. */
import APIClient
import Domain
import Foundation
import HTTPTypes
import Testing

@testable import Features

private let october1 = CalendarDay(year: 2026, month: 10, day: 1)
private let october16 = CalendarDay(year: 2026, month: 10, day: 16)

@Suite("LiveHistoryService")
struct LiveHistoryServiceTests {
    @Test("reads the pay period and the name from GET /me")
    func readsAccount() async throws {
        let (api, _) = KiraAPI.canned(json: liveMeJSON)

        let account = try await LiveHistoryService(api: api).currentAccount()

        #expect(account.displayName == "Dinda")
        #expect(account.period.start == CalendarDay(year: 2026, month: 9, day: 25))
        #expect(account.period.end == CalendarDay(year: 2026, month: 10, day: 24))
        #expect(account.period.daysUntilPayday == 9)
    }

    @Test("sends Riwayat's filters and reads the page")
    func readsTransactions() async throws {
        let (api, transport) = KiraAPI.canned(json: #"{"items":[\#(liveTransactionJSON)],"nextCursor":"c-1"}"#)
        let query = TransactionQuery(
            start: october1, end: october16, type: .expense, category: .transport, text: "grab", cursor: "c-0",
            limit: 30)

        let page = try await LiveHistoryService(api: api).transactions(query)

        let transaction = try #require(page.items.first)
        #expect(transaction.source == .bankImport)
        #expect(transaction.note == "pagi")
        #expect(transaction.occurredAt == liveNow)
        #expect(page.nextCursor == "c-1")
        #expect(
            try #require(await transport.request).path.hasSuffix(
                "transactions?from=2026-10-01&to=2026-10-16&type=expense&category=transport&q=grab&cursor=c-0&limit=30")
        )
    }

    @Test("reads the totals of a range by WIB day")
    func readsSummary() async throws {
        let json = #"{"expense":66000,"income":0,"days":[{"date":"2026-10-16","expense":66000,"income":0}]}"#
        let (api, transport) = KiraAPI.canned(json: json)

        let summary = try await LiveHistoryService(api: api).summary(from: october1, to: october16)

        #expect(summary.expense == 66_000)
        #expect(summary.totals(on: october16).expense == 66_000)
        #expect(try #require(await transport.request).path.hasSuffix("summary?from=2026-10-01&to=2026-10-16"))
    }

    @Test("reads a detail whose source has no text as an empty quote")
    func readsDetail() async throws {
        let (api, _) = KiraAPI.canned(json: liveDetailJSON)

        let detail = try await LiveHistoryService(api: api).transaction(id: "t-1")

        #expect(detail.transaction.id == "t-1")
        #expect(detail.sourceMessage?.body == "")
        #expect(detail.sourceMessage?.createdAt == liveNow)
    }

    @Test("sends an edit and a delete")
    func editsAndDeletes() async throws {
        let (editAPI, editTransport) = KiraAPI.canned(json: liveTransactionJSON)
        let edited = try await LiveHistoryService(api: editAPI).update(id: "t-1", change: TransactionChange(note: ""))
        #expect(edited.id == "t-1")
        let edit = try #require(await editTransport.request)
        #expect(edit.method == .patch)
        #expect(edit.compact == #"{"note":""}"#)

        let (deleteAPI, deleteTransport) = KiraAPI.canned(status: 204)
        try await LiveHistoryService(api: deleteAPI).delete(id: "t-1")
        #expect(try #require(await deleteTransport.request).method == .delete)
    }

    @Test("reads the log around a message")
    func readsConversation() async throws {
        let (api, transport) = KiraAPI.canned(
            json: #"{"items":[\#(livePersonJSON),\#(liveReplyJSON)],"nextCursor":null}"#)

        let messages = try await LiveHistoryService(api: api).messages(around: "m-1")

        #expect(messages.map(\.id) == ["m-1", "m-2"])
        #expect(try #require(await transport.request).path.hasSuffix("chat/messages?around=m-1"))
    }

    @Test("uploads the parsed rows and saves the chosen ones")
    func importsStatement() async throws {
        let row =
            #"{"id":"r-1","date":"2026-10-02","description":"GRAB*TRIP","amount":18000,"type":"expense","#
            + #""category":"transport","isDuplicate":true}"#
        let (uploadAPI, uploadTransport) = KiraAPI.canned(
            status: 201,
            json: #"{"id":"i-1","rowCount":1,"dateFrom":"2026-10-02","dateTo":"2026-10-02","rows":[\#(row)]}"#)
        let statement = try BankStatementParser.parse(
            Data("tanggal,keterangan,nominal\n2026-10-02,GRAB*TRIP,-18000\n".utf8))
        let preview = try await LiveHistoryService(api: uploadAPI).upload(
            ImportUpload(statement: statement, fileName: "mutasi.csv", fileSize: 2048))
        #expect(preview.dateFrom == CalendarDay(year: 2026, month: 10, day: 2))
        #expect(preview.rows.first?.isDuplicate == true)
        let upload = try #require(await uploadTransport.request).compact
        #expect(upload.contains(#""date":"2026-10-02""#))
        #expect(upload.contains(#""amount":-18000"#))

        let (commitAPI, commitTransport) = KiraAPI.canned(json: #"{"savedCount":1,"skippedCount":0}"#)
        let result = try await LiveHistoryService(api: commitAPI).commit(
            importId: "i-1", rows: [ImportCommitRow(id: "r-1", category: .otherIncome)])
        #expect(result == ImportCommitResult(savedCount: 1, skippedCount: 0))
        #expect(try #require(await commitTransport.request).compact.contains(#""category":"other_income""#))
    }

    @Test("throws the generic problem for a day the app cannot read")
    func refusesBadDay() async {
        let json = #"{"expense":0,"income":0,"days":[{"date":"16-10-2026","expense":0,"income":0}]}"#
        let (api, _) = KiraAPI.canned(json: json)
        await #expect(throws: AppProblem()) {
            _ = try await LiveHistoryService(api: api).summary(from: october1, to: october16)
        }
    }
}
