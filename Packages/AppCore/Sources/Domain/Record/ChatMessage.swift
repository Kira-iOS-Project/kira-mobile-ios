import Foundation

/**
 One message of the Catat chat (CAT-01), as `GET /chat/messages` returns it. Fields a kind does not
 use are nil. Kira's sentences are written by the app from the kind and the numbers; only the
 person's text and a receipt's store name come as `body`.
 */
package struct ChatMessage: Identifiable, Hashable, Sendable {
    package let id: String
    package let sender: ChatSender
    package let kind: ChatMessageKind
    package let body: String?
    package let createdAt: Date
    /** The person's message a Kira reply answers. */
    package let replyToId: String?
    package var drafts: [DraftItem]?
    package var draftStatus: DraftStatus?
    package let parser: DraftParserKind?
    package let inputMethod: InputMethod?
    /** The saved transactions' batch, which Urungkan deletes. */
    package var batchId: String?
    package var transactionIds: [String]?
    package var committedAt: Date?
    package let itemCount: Int?
    /** The period's remaining money and its amount per day, for a `remaining` message. */
    package let remaining: Int?
    package let perDay: Int?

    package init(
        id: String, sender: ChatSender, kind: ChatMessageKind, body: String? = nil, createdAt: Date,
        replyToId: String? = nil, drafts: [DraftItem]? = nil, draftStatus: DraftStatus? = nil,
        parser: DraftParserKind? = nil, inputMethod: InputMethod? = nil, batchId: String? = nil,
        transactionIds: [String]? = nil, committedAt: Date? = nil, itemCount: Int? = nil, remaining: Int? = nil,
        perDay: Int? = nil
    ) {
        self.id = id
        self.sender = sender
        self.kind = kind
        self.body = body
        self.createdAt = createdAt
        self.replyToId = replyToId
        self.drafts = drafts
        self.draftStatus = draftStatus
        self.parser = parser
        self.inputMethod = inputMethod
        self.batchId = batchId
        self.transactionIds = transactionIds
        self.committedAt = committedAt
        self.itemCount = itemCount
        self.remaining = remaining
        self.perDay = perDay
    }
}

/** Who wrote a message: the backend's `MESSAGE_SENDER`. */
package enum ChatSender: String, Codable, Sendable {
    case person, kira
}

/** What a message is: the backend's `MESSAGE_KIND`. */
package enum ChatMessageKind: String, Codable, Sendable {
    case personText = "person_text"
    case personReceipt = "person_receipt"
    case drafts
    case manualSaved = "manual_saved"
    case remaining
    case noDrafts = "no_drafts"
}

/** The state of a reply's drafts: the backend's `DRAFT_STATUS`. */
package enum DraftStatus: String, Codable, Sendable {
    case pending, committed, discarded
}

/** What read the text into drafts on the device: the backend's `DRAFT_PARSER`. */
package enum DraftParserKind: String, Codable, Sendable {
    case onDeviceModel = "on_device_model"
    case slangRules = "slang_rules"
}

/** How the person wrote: the backend's `INPUT_METHOD`. */
package enum InputMethod: String, Codable, Sendable {
    case keyboard, voice
}

/** A page of the chat, oldest first, and the cursor of the page before it. */
package struct ChatPage: Sendable {
    package let items: [ChatMessage]
    package let nextCursor: String?

    package init(items: [ChatMessage], nextCursor: String?) {
        self.items = items
        self.nextCursor = nextCursor
    }
}
