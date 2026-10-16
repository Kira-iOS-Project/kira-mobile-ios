import APIClient
import Domain

/**
 The Catat chat's values read from the API client's DTOs, and the drafts written back. The chat's
 words are spelled the same on both sides (`person_text`, `slang_rules`), so they cross by name.
 */
extension ChatMessage {
    /** A message of the chat, or of Riwayat Percakapan's log. */
    init(_ dto: ChatMessageDTO) throws {
        self.init(
            id: dto.id, sender: try Bridge.value(dto.sender), kind: try Bridge.value(dto.kind), body: dto.body,
            createdAt: dto.createdAt, replyToId: dto.replyToId, drafts: dto.drafts?.map(DraftItem.init),
            draftStatus: try dto.draftStatus.map(Bridge.value), batchId: dto.batchId, remaining: dto.remaining,
            perDay: dto.perDay)
    }
}

extension DraftItem {
    /** A draft of a Kira reply. */
    init(_ dto: DraftItemDTO) {
        self.init(
            id: dto.id, type: dto.type, name: dto.name, amount: dto.amount, category: dto.category,
            occurredAt: dto.occurredAt, spanStart: dto.spanStart, spanEnd: dto.spanEnd)
    }
}

extension DraftItemDTO {
    /** A draft as an edit sends it back. */
    init(_ draft: DraftItem) {
        self.init(
            id: draft.id, type: draft.type, name: draft.name, amount: draft.amount, category: draft.category,
            occurredAt: draft.occurredAt, spanStart: draft.spanStart, spanEnd: draft.spanEnd)
    }
}

extension ChatMessageInputDTO {
    /** A new message with the drafts read on the device. */
    init(_ message: OutgoingMessage) throws {
        self.init(
            clientId: message.clientId, text: message.text, inputMethod: try Bridge.value(message.inputMethod),
            voiceSeconds: message.voiceSeconds, parser: try Bridge.value(message.parser),
            drafts: message.drafts.map {
                DraftInputDTO(
                    type: $0.type, name: $0.name, amount: $0.amount, category: $0.category,
                    occurredAt: $0.occurredAt, spanStart: $0.spanStart, spanEnd: $0.spanEnd)
            })
    }
}

extension SendResult {
    /** The stored message, Kira's reply and the quotas after a send. */
    init(_ dto: MessageSentDTO) throws {
        self.init(
            person: try ChatMessage(dto.person), reply: try dto.reply.map(ChatMessage.init),
            quotaExhausted: dto.quotaExhausted, usage: try Usage(dto.usage))
    }
}

extension RecordProfile {
    /** What Catat reads of `GET /me`: the period runs from its first day to its last, in WIB. */
    init(_ account: MeDTO) throws {
        let period = try Bridge.period(account.period)
        self.init(
            displayName: account.displayName, plan: account.plan.id, usage: try Usage(account.usage),
            periodStart: period.start.start, periodEnd: period.end.start, aiEnabled: account.aiEnabled,
            lastExpenseCategory: account.lastExpenseCategory, lastIncomeCategory: account.lastIncomeCategory)
    }
}
