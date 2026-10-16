/**
 A draft transaction, before Simpan turns it into one: as a Kira reply holds it, as the device
 sends it with a message, and an item of a scanned receipt. `spanStart` and `spanEnd` mark the
 characters of the source text it was read from.
 */
import Domain
import Foundation

/** One draft of a Kira reply, with its id; also what an edit sends back. */
package struct DraftItemDTO: Hashable, Sendable {
    /** The draft's id. */
    package let id: String
    /** Which way the money went. */
    package let type: TransactionType
    /** "Kopi Susu". */
    package let name: String
    /** Whole rupiah. */
    package let amount: Int
    /** Its category. */
    package let category: TransactionCategory
    /** When it happened. */
    package let occurredAt: Date
    /** Where it starts in the source text. */
    package let spanStart: Int?
    /** Where it ends in the source text. */
    package let spanEnd: Int?

    /** A draft to send back in an edit. */
    package init(
        id: String, type: TransactionType, name: String, amount: Int, category: TransactionCategory,
        occurredAt: Date, spanStart: Int? = nil, spanEnd: Int? = nil
    ) {
        self.id = id
        self.type = type
        self.name = name
        self.amount = amount
        self.category = category
        self.occurredAt = occurredAt
        self.spanStart = spanStart
        self.spanEnd = spanEnd
    }

    init(_ draft: Components.Schemas.DraftItem) throws {
        self.init(
            id: draft.id, type: try bridged(draft._type), name: draft.name, amount: draft.amount,
            category: try bridged(draft.category), occurredAt: draft.occurredAt,
            spanStart: draft.spanStart, spanEnd: draft.spanEnd)
    }

    func edit() throws -> Components.Schemas.DraftEdit {
        .init(
            _type: try bridged(type), name: name, amount: amount, category: try bridged(category),
            occurredAt: occurredAt, spanStart: spanStart, spanEnd: spanEnd, id: id)
    }
}

/** A draft the device read from a message, sent with it. */
package struct DraftInputDTO: Hashable, Sendable {
    /** Which way the money went. */
    package let type: TransactionType
    /** "Kopi Susu". */
    package let name: String
    /** Whole rupiah. */
    package let amount: Int
    /** Its category; it must belong to `type`. */
    package let category: TransactionCategory
    /** When it happened. */
    package let occurredAt: Date
    /** Where it starts in the message text. */
    package let spanStart: Int?
    /** Where it ends in the message text. */
    package let spanEnd: Int?

    /** A draft to send. */
    package init(
        type: TransactionType, name: String, amount: Int, category: TransactionCategory, occurredAt: Date,
        spanStart: Int? = nil, spanEnd: Int? = nil
    ) {
        self.type = type
        self.name = name
        self.amount = amount
        self.category = category
        self.occurredAt = occurredAt
        self.spanStart = spanStart
        self.spanEnd = spanEnd
    }

    func input() throws -> Components.Schemas.DraftInput {
        .init(
            _type: try bridged(type), name: name, amount: amount, category: try bridged(category),
            occurredAt: occurredAt, spanStart: spanStart, spanEnd: spanEnd)
    }
}

/** One line of a receipt read on the device; receipts hold expenses only. */
package struct ReceiptItemDTO: Hashable, Sendable {
    /** "Roti Tawar". */
    package let name: String
    /** Whole rupiah. */
    package let amount: Int
    /** An expense category; an income one is refused as a generic problem before sending. */
    package let category: TransactionCategory

    /** A receipt line to send. */
    package init(name: String, amount: Int, category: TransactionCategory) {
        self.name = name
        self.amount = amount
        self.category = category
    }

    func item() throws -> Components.Schemas.ReceiptInput.ItemsPayloadPayload {
        .init(name: name, amount: amount, category: try bridged(category))
    }
}

/** A typed or spoken message and the drafts the device read from it (CAT-01, CAT-10). */
package struct ChatMessageInputDTO: Hashable, Sendable {
    /** Chosen by the app, so a retried send stores the message once. */
    package let clientId: String
    /** The text, or the voice transcript. */
    package let text: String
    /** Typed or spoken. */
    package let inputMethod: ChatMessageDTO.InputMethod
    /** The recording's length, for Kira Plus's voice quota. */
    package let voiceSeconds: Int?
    /** What read the drafts. */
    package let parser: ChatMessageDTO.Parser
    /** The drafts; empty when no amount was found. */
    package let drafts: [DraftInputDTO]

    /** A message to send. */
    package init(
        clientId: String, text: String, inputMethod: ChatMessageDTO.InputMethod = .keyboard,
        voiceSeconds: Int? = nil, parser: ChatMessageDTO.Parser, drafts: [DraftInputDTO]
    ) {
        self.clientId = clientId
        self.text = text
        self.inputMethod = inputMethod
        self.voiceSeconds = voiceSeconds
        self.parser = parser
        self.drafts = drafts
    }
}
