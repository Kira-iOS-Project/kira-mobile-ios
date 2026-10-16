/**
 A Catat chat message as Riwayat Percakapan (CAT-08f) reads it: the part of the API's
 `ChatMessage` a read-only log needs. Its own name keeps it apart from the chat screen's model.
 */
import Foundation

/** A message of the chat log, read only. */
package struct ConversationMessage: Identifiable, Hashable, Sendable {
    /** Who wrote it: the backend's `MESSAGE_SENDER`. */
    package enum Sender: String, Codable, Sendable {
        /** The person, or Kira. */
        case person, kira
    }

    /** What it is: the backend's `MESSAGE_KIND`. */
    package enum Kind: String, Codable, Sendable {
        /** Text the person typed or spoke. */
        case personText = "person_text"
        /** A receipt the person scanned. */
        case personReceipt = "person_receipt"
        /** Kira's reply with drafts. */
        case drafts
        /** Kira's note that a manual entry was saved. */
        case manualSaved = "manual_saved"
        /** Kira's engine-computed remaining money. */
        case remaining
        /** Kira's reply when the text held no amount. */
        case noDrafts = "no_drafts"
    }

    /** What became of a reply's drafts: the backend's `DRAFT_STATUS`. */
    package enum DraftStatus: String, Codable, Sendable {
        /** Waiting, saved, or thrown away. */
        case pending, committed, discarded
    }

    /** One draft a reply carries. */
    package struct Draft: Identifiable, Hashable, Sendable {
        /** The draft's id. */
        package let id: String
        /** Money out or money in. */
        package let type: TransactionType
        /** What the draft is called. */
        package let name: String
        /** Its amount in whole rupiah. */
        package let amount: Int
        /** Its category. */
        package let category: TransactionCategory

        /** A draft with the given fields. */
        package init(id: String, type: TransactionType, name: String, amount: Int, category: TransactionCategory) {
            self.id = id
            self.type = type
            self.name = name
            self.amount = amount
            self.category = category
        }
    }

    /** The message's id. */
    package let id: String
    /** Who wrote it. */
    package let sender: Sender
    /** What kind of message it is. */
    package let kind: Kind
    /** The text, for the person's messages. */
    package let body: String?
    /** When it was written. */
    package let createdAt: Date
    /** The person's message a Kira reply answers. */
    package let replyToId: String?
    /** The drafts a reply carries; empty for other messages. */
    package let drafts: [Draft]
    /** What became of the drafts. */
    package let draftStatus: DraftStatus?
    /** For a `remaining` message: the money left in the period and per day, from the engine. */
    package let remaining: Int?
    /** The money left per day, for a `remaining` message. */
    package let perDay: Int?

    /** A message with the given fields. */
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
