/** The transaction calls through a canned transport: what they send, read and throw. */
import Domain
import Foundation
import HTTPTypes
import Testing

@testable import APIClient

private let entry = ManualTransactionInputDTO(
    clientId: "c-1", type: .expense, amount: 18_000, category: .transport, name: "Grab ke Kantor",
    occurredAt: recordNow, note: "pagi")

@Suite("TransactionAPI")
struct TransactionAPITests {
    @Test("saves a manual entry and reads Kira's note")
    func createsManual() async throws {
        let (api, transport) = KiraAPI.canned(
            status: 201, json: #"{"transaction":\#(transactionJSON),"message":\#(personJSON)}"#)

        let saved = try await api.createTransaction(entry)

        #expect(saved.message.id == "m-1")
        let body = try decodeSent(
            Components.Schemas.ManualTransactionInput.self, from: try #require(await transport.request))
        #expect(body.note == "pagi")
        #expect(body.category == .transport)
        #expect(body.occurredAt == recordNow)
    }

    @Test("lists with every filter in the query")
    func listsWithFilters() async throws {
        let (api, transport) = KiraAPI.canned(json: #"{"items":[\#(transactionJSON)],"nextCursor":null}"#)
        let query = TransactionQueryDTO(
            firstDay: "2026-10-01", lastDay: "2026-10-16", type: .expense, category: .transport, search: "grab",
            cursor: "c-0", limit: 5)

        let page = try await api.listTransactions(query)

        #expect(page.items.map(\.id) == ["t-1"])
        #expect(page.nextCursor == nil)
        #expect(
            try #require(await transport.request).path.hasSuffix(
                "transactions?from=2026-10-01&to=2026-10-16&type=expense&category=transport&q=grab&cursor=c-0&limit=5"))
    }

    @Test("reads the totals of a range")
    func summarizes() async throws {
        let json = #"{"expense":66000,"income":0,"days":[{"date":"2026-10-16","expense":66000,"income":0}]}"#
        let (api, transport) = KiraAPI.canned(json: json)

        let summary = try await api.summarizeTransactions(firstDay: "2026-10-01", lastDay: "2026-10-16")

        #expect(summary.expense == 66_000)
        #expect(summary.days.first?.date == "2026-10-16")
        #expect(
            try #require(await transport.request).path.hasSuffix("transactions/summary?from=2026-10-01&to=2026-10-16"))
    }

    @Test("reads a detail with and without its source message")
    func readsDetail() async throws {
        let quote =
            #""sourceMessage":{"id":"m-1","body":"grab 18rb","createdAt":"\#(recordNowJSON)","#
            + #""spanStart":0,"spanEnd":4}"#
        let withSource = String(transactionJSON.dropLast()) + "," + quote + "}"
        let (api, _) = KiraAPI.canned(json: withSource)
        let detail = try await api.getTransaction(id: "t-1")
        #expect(detail.sourceMessage?.spanEnd == 4)
        #expect(detail.sourceMessage?.createdAt == recordNow)
        #expect(detail.transaction.name == "Grab ke Kantor")

        let (plainAPI, _) = KiraAPI.canned(json: String(transactionJSON.dropLast()) + #","sourceMessage":null}"#)
        #expect(try await plainAPI.getTransaction(id: "t-1").sourceMessage == nil)
    }

    @Test("edits, deletes and undoes")
    func editsDeletesUndoes() async throws {
        let (editAPI, editTransport) = KiraAPI.canned(json: transactionJSON)
        _ = try await editAPI.updateTransaction(id: "t-1", change: .init(amount: 20_000, category: .bonus))
        let edit = try #require(await editTransport.request)
        #expect(edit.method == .patch)
        let body = try decodeSent(Components.Schemas.TransactionUpdate.self, from: edit)
        #expect(body.amount == 20_000)
        #expect(body.category == .bonus)
        #expect(body.name == nil)

        let (deleteAPI, deleteTransport) = KiraAPI.canned(status: 204)
        try await deleteAPI.deleteTransaction(id: "t-1")
        #expect(try #require(await deleteTransport.request).method == .delete)

        let (undoAPI, undoTransport) = KiraAPI.canned(json: replyJSON)
        #expect(try await undoAPI.undoTransactionBatch(batchId: "b-1").id == "m-2")
        #expect(try #require(await undoTransport.request).path.hasSuffix("transactions/batches/b-1"))
    }

    @Test("throws the problem of a failure", arguments: Self.failures)
    func throwsProblems(failure: FailureCase) async {
        let (api, _) = KiraAPI.canned(status: failure.status, json: problemJSON("X_CODE"))
        await #expect(throws: failure.expectedProblem(documented: failure.status != 500)) {
            try await failure.call(api)
        }
    }

    static let failures: [FailureCase] =
        failureCases("createTransaction", statuses: [401, 422]) { _ = try await $0.createTransaction(entry) }
        + failureCases("listTransactions", statuses: [401, 422]) { _ = try await $0.listTransactions() }
        + failureCases("summarizeTransactions", statuses: [401, 422]) {
            _ = try await $0.summarizeTransactions(firstDay: "2026-10-01", lastDay: "2026-10-16")
        }
        + failureCases("getTransaction", statuses: [401, 404, 422]) { _ = try await $0.getTransaction(id: "t") }
        + failureCases("updateTransaction", statuses: [401, 404, 422]) {
            _ = try await $0.updateTransaction(id: "t", change: .init(name: "x"))
        }
        + failureCases("deleteTransaction", statuses: [401, 404, 422]) { try await $0.deleteTransaction(id: "t") }
        + failureCases("undoTransactionBatch", statuses: [401, 404, 409, 422]) {
            _ = try await $0.undoTransactionBatch(batchId: "b")
        }
}
