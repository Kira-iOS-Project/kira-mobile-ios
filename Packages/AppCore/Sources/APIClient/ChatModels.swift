/**
 What the Catat chat sends and answers (CAT-01 to CAT-06, CAT-10): its messages, the drafts a Kira
 reply carries, and the inputs of a typed message or a scanned receipt. Amounts are whole rupiah;
 `createdAt`, `occurredAt` and `committedAt` are instants. The words of a message are nested in
 `ChatMessageDTO` so they never meet the screens' own vocabulary of the same names.
 */
import Domain
import Foundation

/** One message of the Catat chat; a field its kind does not use is nil. */
package struct ChatMessageDTO: Hashable, Sendable {
    /** Who wrote it. */
    package enum Sender: String, Sendable {
        /** The person using Kira. */
        case person
        /** Kira's reply. */
        case kira
    }

    /** What the message is. */
    package enum Kind: String, Sendable {
        /** Typed or spoken text. */
        case personText = "person_text"
        /** A scanned receipt; `body` is the store name. */
        case personReceipt = "person_receipt"
        /** Kira's drafts to confirm. */
        case drafts
        /** Kira's note that a manual entry was saved. */
        case manualSaved = "manual_saved"
        /** Kira's engine-computed remaining money after a save. */
        case remaining
        /** Kira read no amount in the text. */
        case noDrafts = "no_drafts"
    }

    /** Where a reply's drafts stand. */
    package enum DraftStatus: String, Sendable {
        /** Waiting for Simpan or an edit. */
        case pending
        /** Saved as transactions. */
        case committed
        /** All drafts were removed. */
        case discarded
    }

    /** What turned the text into drafts on the device. */
    package enum Parser: String, Sendable {
        /** Apple Foundation Models. */
        case onDeviceModel = "on_device_model"
        /** The deterministic slang rules. */
        case slangRules = "slang_rules"
    }

    /** How the text was entered. */
    package enum InputMethod: String, Sendable {
        /** Typed. */
        case keyboard
        /** Spoken and transcribed on the device (Kira Plus). */
        case voice
    }

    /** The message's id. */
    package let id: String
    /** Who wrote it. */
    package let sender: Sender
    /** What it is. */
    package let kind: Kind
    /** The person's text, or a receipt's store name. */
    package let body: String?
    /** When it was stored. */
    package let createdAt: Date
    /** The person's message a Kira reply answers. */
    package let replyToId: String?
    /** A drafts reply's items. */
    package let drafts: [DraftItemDTO]?
    /** Where those drafts stand. */
    package let draftStatus: DraftStatus?
    /** What read the drafts. */
    package let parser: Parser?
    /** How a person's text was entered. */
    package let inputMethod: InputMethod?
    /** The save batch, for Urungkan. */
    package let batchId: String?
    /** The transactions a save created. */
    package let transactionIds: [String]?
    /** When the drafts were saved. */
    package let committedAt: Date?
    /** How many transactions a save held. */
    package let itemCount: Int?
    /** Sisa uang after a save; negative when overspent. */
    package let remaining: Int?
    /** What that leaves per day until payday. */
    package let perDay: Int?

    init(_ message: Components.Schemas.ChatMessage) throws {
        id = message.id
        sender = try bridged(message.sender)
        kind = try bridged(message.kind)
        body = message.body
        createdAt = message.createdAt
        replyToId = message.replyToId
        drafts = try message.drafts?.map(DraftItemDTO.init)
        draftStatus = try bridged(message.draftStatus)
        parser = try bridged(message.parser)
        inputMethod = try bridged(message.inputMethod)
        batchId = message.batchId
        transactionIds = message.transactionIds
        committedAt = message.committedAt
        itemCount = message.itemCount
        remaining = message.remaining
        perDay = message.perDay
    }
}

/** A page of the chat, oldest first, and the cursor to the older page. */
package struct ChatPageDTO: Hashable, Sendable {
    /** The messages, oldest first. */
    package let items: [ChatMessageDTO]
    /** Pass as `before` for the older page; nil on the oldest. */
    package let nextCursor: String?

    init(_ page: Components.Schemas.ChatMessagePage) throws {
        items = try page.items.map(ChatMessageDTO.init)
        nextCursor = page.nextCursor
    }
}

/** What a send stored: the person's message, Kira's reply and the quota left. */
package struct MessageSentDTO: Hashable, Sendable {
    /** The message as stored. */
    package let person: ChatMessageDTO
    /** Kira's reply; nil when the quota ran out (CAT-09). */
    package let reply: ChatMessageDTO?
    /** The quota ran out: show Kuota AI; the message is kept. */
    package let quotaExhausted: Bool
    /** The usage after this send. */
    package let usage: UsageDTO

    init(_ sent: Components.Schemas.ChatMessageSent) throws {
        person = try ChatMessageDTO(sent.person)
        reply = try sent.reply.map { try ChatMessageDTO($0.value1) }
        quotaExhausted = sent.quotaExhausted
        usage = UsageDTO(sent.usage)
    }
}

/** A saved reply and Kira's remaining-money message (CAT-03). */
package struct DraftsCommittedDTO: Hashable, Sendable {
    /** The reply, now committed, with its batch and transactions. */
    package let message: ChatMessageDTO
    /** Kira's remaining-money message. */
    package let remaining: ChatMessageDTO

    init(_ committed: Components.Schemas.DraftsCommitted) throws {
        message = try ChatMessageDTO(committed.message)
        remaining = try ChatMessageDTO(committed.remaining)
    }
}
