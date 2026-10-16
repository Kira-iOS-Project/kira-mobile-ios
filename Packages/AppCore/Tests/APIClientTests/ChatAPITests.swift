/** The Catat chat calls through a canned transport: what they send, read and throw. */
import Domain
import Foundation
import HTTPTypes
import Testing

@testable import APIClient

private let draft = DraftInputDTO(
    type: .expense, name: "Kopi Susu", amount: 25_000, category: .coffee, occurredAt: recordNow, spanStart: 0,
    spanEnd: 9)
private let sentJSON = #"{"person":\#(personJSON),"reply":\#(replyJSON),"quotaExhausted":false,"usage":\#(usageJSON)}"#

@Suite("ChatAPI")
struct ChatAPITests {
    @Test("reads a page of messages, every field of a reply included")
    func readsPage() async throws {
        let (api, transport) = KiraAPI.canned(json: #"{"items":[\#(personJSON),\#(replyJSON)],"nextCursor":"c-1"}"#)

        let page = try await api.listChatMessages(before: "c-0", limit: 10)

        #expect(page.nextCursor == "c-1")
        let person = try #require(page.items.first)
        #expect(person.kind == .personText)
        #expect(person.sender == .person)
        #expect(person.drafts == nil)
        let reply = try #require(page.items.last)
        #expect(reply.sender == .kira)
        #expect(reply.kind == .drafts)
        #expect(reply.draftStatus == .committed)
        #expect(reply.remaining == 1_840_000)
        #expect(reply.perDay == 184_000)
        #expect(reply.drafts?.first?.category == .coffee)
        #expect(reply.drafts?.first?.occurredAt == recordNow)
        let sent = try #require(await transport.request)
        #expect(sent.path.hasSuffix("chat/messages?before=c-0&limit=10"))
    }

    @Test("sends a message with its drafts and reads the reply and the usage")
    func sendsMessage() async throws {
        let (api, transport) = KiraAPI.canned(status: 201, json: sentJSON)
        let message = ChatMessageInputDTO(
            clientId: "c-1", text: "kopi susu 25rb", inputMethod: .voice, voiceSeconds: 4, parser: .slangRules,
            drafts: [draft])

        let result = try await api.sendChatMessage(message)

        #expect(result.reply?.id == "m-2")
        #expect(result.quotaExhausted == false)
        #expect(result.usage.aiMessages.used == 1)
        let sent = try #require(await transport.request)
        #expect(sent.method == .post)
        let body = try decodeSent(Components.Schemas.ChatMessageInput.self, from: sent)
        #expect(body.inputMethod == .voice)
        #expect(body.voiceSeconds == 4)
        #expect(body.drafts.first?.occurredAt == recordNow)
        #expect(body.drafts.first?._type == .expense)
    }

    @Test("reads a spent quota as no reply")
    func readsSpentQuota() async throws {
        let json = #"{"person":\#(personJSON),"reply":null,"quotaExhausted":true,"usage":\#(usageJSON)}"#
        let (api, _) = KiraAPI.canned(status: 201, json: json)

        let result = try await api.sendChatMessage(
            .init(clientId: "c-1", text: "kopi", parser: .onDeviceModel, drafts: []))

        #expect(result.reply == nil)
        #expect(result.quotaExhausted)
    }

    @Test("sends a receipt's items")
    func sendsReceipt() async throws {
        let (api, transport) = KiraAPI.canned(status: 201, json: sentJSON)
        let items = [ReceiptItemDTO(name: "Roti", amount: 12_000, category: .food)]

        _ = try await api.sendReceipt(
            clientId: "c-2", storeName: "Indomaret", occurredAt: recordNow, total: 12_000, items: items)

        let body = try decodeSent(Components.Schemas.ReceiptInput.self, from: try #require(await transport.request))
        #expect(body.storeName == "Indomaret")
        #expect(body.items.first?.category == .food)
    }

    @Test("refuses an income category on a receipt before sending")
    func refusesIncomeReceiptItem() async throws {
        let (api, transport) = KiraAPI.canned(status: 201, json: sentJSON)
        let items = [ReceiptItemDTO(name: "Gaji", amount: 1, category: .salary)]

        await #expect(throws: AppProblem()) {
            _ = try await api.sendReceipt(clientId: "c", storeName: "x", occurredAt: recordNow, total: 1, items: items)
        }
        #expect(await transport.requests.isEmpty)
    }

    @Test("sends edited drafts and saves them")
    func editsAndCommits() async throws {
        let (editAPI, editTransport) = KiraAPI.canned(json: replyJSON)
        let edit = DraftItemDTO(
            id: "d-1", type: .income, name: "Bonus", amount: 1, category: .bonus, occurredAt: recordNow)

        let edited = try await editAPI.updateChatDrafts(messageId: "m-2", drafts: [edit])

        #expect(edited.id == "m-2")
        let sent = try #require(await editTransport.request)
        #expect(sent.method == .put)
        #expect(sent.path.hasSuffix("chat/messages/m-2/drafts"))
        let body = try decodeSent(Components.Schemas.DraftsUpdate.self, from: sent)
        #expect(body.drafts.first?.id == "d-1")
        #expect(body.drafts.first?.category == .bonus)

        let (commitAPI, commitTransport) = KiraAPI.canned(json: #"{"message":\#(replyJSON),"remaining":\#(replyJSON)}"#)
        let committed = try await commitAPI.commitChatDrafts(messageId: "m-2")
        #expect(committed.remaining.remaining == 1_840_000)
        #expect(try #require(await commitTransport.request).path.hasSuffix("chat/messages/m-2/commit"))
    }

    @Test("throws the problem of a failure", arguments: Self.failures)
    func throwsProblems(failure: FailureCase) async {
        let (api, _) = KiraAPI.canned(status: failure.status, json: problemJSON("X_CODE"))
        await #expect(throws: failure.expectedProblem(documented: failure.status != 500)) {
            try await failure.call(api)
        }
    }

    static let failures: [FailureCase] =
        failureCases("listChatMessages", statuses: [401, 404, 422]) { _ = try await $0.listChatMessages(around: "m") }
        + failureCases("sendChatMessage", statuses: [401, 403, 422]) {
            _ = try await $0.sendChatMessage(.init(clientId: "c", text: "t", parser: .slangRules, drafts: [draft]))
        }
        + failureCases("sendReceipt", statuses: [400, 401, 403, 422]) {
            _ = try await $0.sendReceipt(clientId: "c", storeName: "s", occurredAt: recordNow, total: 1, items: [])
        }
        + failureCases("updateChatDrafts", statuses: [401, 404, 409, 422]) {
            _ = try await $0.updateChatDrafts(messageId: "m", drafts: [])
        }
        + failureCases("commitChatDrafts", statuses: [401, 404, 409, 422]) {
            _ = try await $0.commitChatDrafts(messageId: "m")
        }
}
