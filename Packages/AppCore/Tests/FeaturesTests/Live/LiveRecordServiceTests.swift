/** LiveRecordService over a canned transport: each call's request and its Domain values. */
import APIClient
import Domain
import Foundation
import HTTPTypes
import Testing

@testable import Features

@Suite("LiveRecordService")
struct LiveRecordServiceTests {
    @Test("reads Catat's profile from GET /me, the period from its first to its last WIB day")
    func readsProfile() async throws {
        let (api, transport) = KiraAPI.canned(json: liveMeJSON)

        let profile = try await LiveRecordService(api: api).profile()

        #expect(profile.displayName == "Dinda")
        #expect(profile.plan == .free)
        #expect(profile.aiEnabled)
        #expect(profile.periodStart == CalendarDay(year: 2026, month: 9, day: 25).start)
        #expect(profile.periodEnd == CalendarDay(year: 2026, month: 10, day: 24).start)
        #expect(profile.usage.aiMessages == UsageMeter(used: 1, limit: 30))
        #expect(profile.usage.resetsOn == CalendarDay(year: 2026, month: 11, day: 1))
        #expect(profile.lastExpenseCategory == .food)
        #expect(profile.lastIncomeCategory == nil)
        #expect(try #require(await transport.request).path.hasSuffix("me"))
    }

    @Test("reads a page of messages with every field of a reply")
    func readsMessages() async throws {
        let json = #"{"items":[\#(livePersonJSON),\#(liveReplyJSON)],"nextCursor":"c-1"}"#
        let (api, transport) = KiraAPI.canned(json: json)

        let page = try await LiveRecordService(api: api).messages(before: "c-0")

        #expect(page.nextCursor == "c-1")
        let reply = try #require(page.items.last)
        #expect(reply.sender == .kira)
        #expect(reply.kind == .drafts)
        #expect(reply.draftStatus == .committed)
        #expect(reply.parser == .slangRules)
        #expect(reply.inputMethod == .keyboard)
        #expect(reply.drafts?.first?.category == .coffee)
        #expect(reply.committedAt == liveNow)
        #expect(reply.remaining == 1_840_000)
        #expect(page.items.first?.drafts == nil)
        #expect(try #require(await transport.request).path.hasSuffix("chat/messages?before=c-0"))
    }

    @Test("sends a message with its drafts and reads the reply and the quotas")
    func sends() async throws {
        let (api, transport) = KiraAPI.canned(status: 201, json: liveSentJSON)
        let draft = DraftInput(
            type: .expense, name: "Kopi Susu", amount: 25_000, category: .coffee, occurredAt: liveNow, spanStart: 0,
            spanEnd: 9)
        let message = OutgoingMessage(
            clientId: "c-1", text: "kopi susu 25rb", inputMethod: .voice, voiceSeconds: 4, parser: .onDeviceModel,
            drafts: [draft])

        let result = try await LiveRecordService(api: api).send(message)

        #expect(result.reply?.id == "m-2")
        #expect(result.quotaExhausted == false)
        #expect(result.usage.receipts == UsageMeter(used: 0, limit: 10))
        let sent = try #require(await transport.request)
        #expect(sent.method == .post)
        #expect(sent.compact.contains(#""inputMethod":"voice""#))
        #expect(sent.compact.contains(#""parser":"on_device_model""#))
        #expect(sent.compact.contains(#""category":"coffee""#))
    }

    @Test("sends edited drafts, saves them and takes the save back")
    func editsCommitsUndoes() async throws {
        let edit = DraftItem(id: "d-1", type: .income, name: "Bonus", amount: 1, category: .bonus, occurredAt: liveNow)
        let (editAPI, editTransport) = KiraAPI.canned(json: liveReplyJSON)
        #expect(try await LiveRecordService(api: editAPI).updateDrafts(messageId: "m-2", drafts: [edit]).id == "m-2")
        let sent = try #require(await editTransport.request)
        #expect(sent.method == .put)
        #expect(sent.compact.contains(#""id":"d-1""#))

        let (commitAPI, _) = KiraAPI.canned(json: #"{"message":\#(liveReplyJSON),"remaining":\#(liveReplyJSON)}"#)
        let committed = try await LiveRecordService(api: commitAPI).commit(messageId: "m-2")
        #expect(committed.remaining.perDay == 184_000)

        let (undoAPI, undoTransport) = KiraAPI.canned(json: liveReplyJSON)
        #expect(try await LiveRecordService(api: undoAPI).undo(batchId: "b-1").batchId == "b-1")
        #expect(try #require(await undoTransport.request).path.hasSuffix("transactions/batches/b-1"))
    }

    @Test("sends a receipt's items and a manual entry")
    func sendsReceiptAndManual() async throws {
        let (receiptAPI, receiptTransport) = KiraAPI.canned(status: 201, json: liveSentJSON)
        let receipt = ReceiptInput(
            clientId: "c-2", storeName: "Indomaret", occurredAt: liveNow, total: 12_000,
            items: [ReceiptItemInput(name: "Roti", amount: 12_000, category: .food)])
        #expect(try await LiveRecordService(api: receiptAPI).sendReceipt(receipt).person.id == "m-1")
        #expect(try #require(await receiptTransport.request).compact.contains(#""storeName":"Indomaret""#))

        let (manualAPI, manualTransport) = KiraAPI.canned(
            status: 201, json: #"{"transaction":\#(liveTransactionJSON),"message":\#(liveReplyJSON)}"#)
        let entry = ManualTransactionInput(
            clientId: "c-3", type: .expense, amount: 18_000, category: .transport, name: "Grab", occurredAt: liveNow,
            note: "pagi")
        let saved = try await LiveRecordService(api: manualAPI).saveManual(entry)
        #expect(saved.transactionId == "t-1")
        #expect(saved.message.id == "m-2")
        #expect(try #require(await manualTransport.request).compact.contains(#""note":"pagi""#))
    }

    @Test("throws the problem the API answered with")
    func throwsProblem() async {
        let body = #"{"type":"\#(AppProblem.typeBase)CHAT_AI_DISABLED","code":"CHAT_AI_DISABLED","requestId":"r-1"}"#
        let (api, _) = KiraAPI.canned(status: 403, json: body)
        await #expect(
            throws: AppProblem(
                type: AppProblem.typeBase + "CHAT_AI_DISABLED", code: "CHAT_AI_DISABLED", requestId: "r-1")
        ) {
            _ = try await LiveRecordService(api: api).send(
                OutgoingMessage(
                    clientId: "c", text: "t", inputMethod: .keyboard, voiceSeconds: nil, parser: .slangRules, drafts: []
                ))
        }
    }
}
