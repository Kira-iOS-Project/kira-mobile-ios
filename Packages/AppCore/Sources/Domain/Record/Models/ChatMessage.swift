import Foundation

/**
 One message of the Catat chat (CAT-01), as `GET /chat/messages` returns it. Fields a kind does not
 use are nil. Kira's sentences are written by the app from the kind and the numbers; only the
 person's text and a receipt's store name come as `body`.
 */
package struct ChatMessage: Identifiable, Hashable, Sendable {
    /** The message's id. */
    package let id: String
    /** Who wrote it. */
    package let sender: ChatSender
    /** What it is. */
    package let kind: ChatMessageKind
    /** The person's text, or a receipt's store name. */
    package let body: String?
    /** When it was written. */
    package let createdAt: Date
    /** The person's message a Kira reply answers. */
    package let replyToId: String?
    /** The drafts of a `drafts` reply. */
    package var drafts: [DraftItem]?
    /** Whether the drafts wait, were saved or were discarded. */
    package var draftStatus: DraftStatus?
    /** The saved transactions' batch, which Urungkan deletes. */
    package var batchId: String?
    /** The period's remaining money and its amount per day, for a `remaining` message. */
    package let remaining: Int?
    /** The remaining money per day left in the period. */
    package let perDay: Int?

    /** A message with the fields its kind uses. */
    package init(
        id: String, sender: ChatSender, kind: ChatMessageKind, body: String? = nil, createdAt: Date,
        replyToId: String? = nil, drafts: [DraftItem]? = nil, draftStatus: DraftStatus? = nil,
        batchId: String? = nil, remaining: Int? = nil, perDay: Int? = nil
    ) {
        self.id = id
        self.sender = sender
        self.kind = kind
        self.body = body
        self.createdAt = createdAt
        self.replyToId = replyToId
        self.drafts = drafts
        self.draftStatus = draftStatus
        self.batchId = batchId
        self.remaining = remaining
        self.perDay = perDay
    }
}

extension ChatMessage {
    /** The drafts' total, the big amount on top of the card ("Total 3 pengeluaran"). */
    package var draftTotal: Int { (drafts ?? []).map(\.amount).reduce(0, +) }

    /** Whether the drafts are all expenses, all income, or both (nil), for "3 pengeluaran". */
    package var draftType: TransactionType? {
        let types = Set((drafts ?? []).map(\.type))
        return types.count == 1 ? types.first : nil
    }
}

/** Who wrote a message: the backend's `MESSAGE_SENDER`. */
package enum ChatSender: String, Codable, Sendable {
    /** The person or Kira. */
    case person, kira
}

/** What a message is: the backend's `MESSAGE_KIND`. */
package enum ChatMessageKind: String, Codable, Sendable {
    /** The person's typed or spoken text. */
    case personText = "person_text"
    /** A receipt the person scanned. */
    case personReceipt = "person_receipt"
    /** Kira's reply with drafts to confirm. */
    case drafts
    /** Kira's note that a manual entry was saved. */
    case manualSaved = "manual_saved"
    /** The engine's remaining money after a save. */
    case remaining
    /** Kira's reply to text without an amount. */
    case noDrafts = "no_drafts"
}

/** The state of a reply's drafts: the backend's `DRAFT_STATUS`. */
package enum DraftStatus: String, Codable, Sendable {
    /** Waiting, saved, or removed. */
    case pending, committed, discarded
}

/** What read the text into drafts on the device: the backend's `DRAFT_PARSER`. */
package enum DraftParserKind: String, Codable, Sendable {
    /** Apple's Foundation Models on the device. */
    case onDeviceModel = "on_device_model"
    /** The deterministic slang rules. */
    case slangRules = "slang_rules"
}

/** How the person wrote: the backend's `INPUT_METHOD`. */
package enum InputMethod: String, Codable, Sendable {
    /** Typed or spoken. */
    case keyboard, voice
}

/** A page of the chat, oldest first, and the cursor of the page before it. */
package struct ChatPage: Sendable {
    /** The messages, oldest first. */
    package let items: [ChatMessage]
    /** The cursor of the page before, or nil at the start. */
    package let nextCursor: String?

    /** A page and its cursor. */
    package init(items: [ChatMessage], nextCursor: String?) {
        self.items = items
        self.nextCursor = nextCursor
    }
}
