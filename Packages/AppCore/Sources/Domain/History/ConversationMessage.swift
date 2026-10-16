/**
 A Catat chat message as Riwayat Percakapan (CAT-08f) reads it: the part of the API's
 `ChatMessage` a read-only log needs. Its own name keeps it apart from the chat screen's model.
 */
import Foundation

/** A message of the chat log, read only. */
package struct ConversationMessage: Identifiable, Hashable, Sendable {
    /** Who wrote it: the backend's `MESSAGE_SENDER`. */
    package enum Sender: String, Codable, Sendable {
        case person, kira
    }

    /** What it is: the backend's `MESSAGE_KIND`. */
    package enum Kind: String, Codable, Sendable {
        case personText = "person_text"
        case personReceipt = "person_receipt"
        case drafts
        case manualSaved = "manual_saved"
        case remaining
        case noDrafts = "no_drafts"
    }

    /** What became of a reply's drafts: the backend's `DRAFT_STATUS`. */
    package enum DraftStatus: String, Codable, Sendable {
        case pending, committed, discarded
    }

    /** One draft a reply carries. */
    package struct Draft: Identifiable, Hashable, Sendable {
        package let id: String
        package let name: String
        package let amount: Int
        package let category: TransactionCategory

        package init(id: String, name: String, amount: Int, category: TransactionCategory) {
            self.id = id
            self.name = name
            self.amount = amount
            self.category = category
        }
    }

    package let id: String
    package let sender: Sender
    package let kind: Kind
    package let body: String?
    package let createdAt: Date
    /** The person's message a Kira reply answers. */
    package let replyToId: String?
    package let drafts: [Draft]
    package let draftStatus: DraftStatus?
    /** For a `remaining` message: the money left in the period and per day, from the engine. */
    package let remaining: Int?
    package let perDay: Int?

    package init(
        id: String, sender: Sender, kind: Kind, body: String?, createdAt: Date, replyToId: String? = nil,
        drafts: [Draft] = [], draftStatus: DraftStatus? = nil, remaining: Int? = nil, perDay: Int? = nil
    ) {
        self.id = id
        self.sender = sender
        self.kind = kind
        self.body = body
        self.createdAt = createdAt
        self.replyToId = replyToId
        self.drafts = drafts
        self.draftStatus = draftStatus
        self.remaining = remaining
        self.perDay = perDay
    }
}
