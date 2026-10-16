/**
 The Catat chat (tag Catat): reading the history, sending a message or a receipt the device has
 already read, editing a reply's drafts and saving them (CAT-01 to CAT-06, CAT-08f, CAT-10).
 */
import Foundation

extension KiraAPI {
    /** A page of older messages by `before`, or a window centred on the message `around`. */
    package func listChatMessages(
        before: String? = nil, around: String? = nil, limit: Int? = nil
    ) async throws -> ChatPageDTO {
        try await client.listChatMessages(query: .init(before: before, around: around, limit: limit)).page()
    }

    /** Sends a message with the drafts read on the device; idempotent on `clientId`. */
    package func sendChatMessage(_ message: ChatMessageInputDTO) async throws -> MessageSentDTO {
        let body = Components.Schemas.ChatMessageInput(
            clientId: message.clientId, text: message.text, inputMethod: try bridged(message.inputMethod),
            voiceSeconds: message.voiceSeconds, parser: try bridged(message.parser),
            drafts: try message.drafts.map { try $0.input() })
        return try await client.sendChatMessage(body: .json(body)).sent()
    }

    /** Sends a receipt read on the device; its items must add up to `total`. */
    package func sendReceipt(
        clientId: String, storeName: String, occurredAt: Date, total: Int, items: [ReceiptItemDTO]
    ) async throws -> MessageSentDTO {
        let body = Components.Schemas.ReceiptInput(
            clientId: clientId, storeName: storeName, occurredAt: occurredAt, total: total,
            items: try items.map { try $0.item() })
        return try await client.sendReceipt(body: .json(body)).sent()
    }

    /** Replaces a pending reply's drafts; an empty list discards them. */
    package func updateChatDrafts(messageId: String, drafts: [DraftItemDTO]) async throws -> ChatMessageDTO {
        let body = Components.Schemas.DraftsUpdate(drafts: try drafts.map { try $0.edit() })
        return try await client.updateChatDrafts(path: .init(id: messageId), body: .json(body)).message()
    }

    /** Saves a reply's drafts as transactions (Simpan). */
    package func commitChatDrafts(messageId: String) async throws -> DraftsCommittedDTO {
        try await client.commitChatDrafts(path: .init(id: messageId)).committed()
    }
}

extension Operations.ListChatMessages.Output {
    func page() throws -> ChatPageDTO {
        switch self {
        case .ok(let response): return try ChatPageDTO(response.body.json)
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .notFound(let response): throw try response.body.applicationProblemJson
        case .unprocessableContent(let response): throw try response.body.applicationProblemJson
        case .undocumented: throw AppProblem()
        }
    }
}

extension Operations.SendChatMessage.Output {
    func sent() throws -> MessageSentDTO {
        switch self {
        case .created(let response): return try MessageSentDTO(response.body.json)
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .forbidden(let response): throw try response.body.applicationProblemJson
        case .unprocessableContent(let response): throw try response.body.applicationProblemJson
        case .undocumented: throw AppProblem()
        }
    }
}

extension Operations.SendReceipt.Output {
    func sent() throws -> MessageSentDTO {
        switch self {
        case .created(let response): return try MessageSentDTO(response.body.json)
        case .badRequest(let response): throw try response.body.applicationProblemJson
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .forbidden(let response): throw try response.body.applicationProblemJson
        case .unprocessableContent(let response): throw try response.body.applicationProblemJson
        case .undocumented: throw AppProblem()
        }
    }
}

extension Operations.UpdateChatDrafts.Output {
    func message() throws -> ChatMessageDTO {
        switch self {
        case .ok(let response): return try ChatMessageDTO(response.body.json)
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .notFound(let response): throw try response.body.applicationProblemJson
        case .conflict(let response): throw try response.body.applicationProblemJson
        case .unprocessableContent(let response): throw try response.body.applicationProblemJson
        case .undocumented: throw AppProblem()
        }
    }
}

extension Operations.CommitChatDrafts.Output {
    func committed() throws -> DraftsCommittedDTO {
        switch self {
        case .ok(let response): return try DraftsCommittedDTO(response.body.json)
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .notFound(let response): throw try response.body.applicationProblemJson
        case .conflict(let response): throw try response.body.applicationProblemJson
        case .unprocessableContent(let response): throw try response.body.applicationProblemJson
        case .undocumented: throw AppProblem()
        }
    }
}
