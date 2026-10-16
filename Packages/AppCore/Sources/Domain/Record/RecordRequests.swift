import Foundation

/** A new chat message with the drafts the device read from it: `POST /chat/messages`. */
package struct OutgoingMessage: Hashable, Sendable {
    /** The idempotency key: the same message sent twice is stored once. */
    package let clientId: String
    /** What the person wrote or said. */
    package let text: String
    /** Typed or spoken. */
    package let inputMethod: InputMethod
    /** The seconds of voice used, for a spoken message. */
    package let voiceSeconds: Int?
    /** What read the drafts. */
    package let parser: DraftParserKind
    /** The drafts read from the text. */
    package let drafts: [DraftInput]

    /** A message to send. */
    package init(
        clientId: String, text: String, inputMethod: InputMethod, voiceSeconds: Int?, parser: DraftParserKind,
        drafts: [DraftInput]
    ) {
        self.clientId = clientId
        self.text = text
        self.inputMethod = inputMethod
        self.voiceSeconds = voiceSeconds
        self.parser = parser
        self.drafts = drafts
    }
}

/** The stored message, Kira's reply (nil when the quota ran out) and the quotas after it. */
package struct SendResult: Sendable {
    /** The person's stored message. */
    package let person: ChatMessage
    /** Kira's reply, or nil when the quota ran out. */
    package let reply: ChatMessage?
    /** Whether the AI quota ran out with this message. */
    package let quotaExhausted: Bool
    /** The quotas after this message. */
    package let usage: Usage

    /** The answer to a sent message. */
    package init(person: ChatMessage, reply: ChatMessage?, quotaExhausted: Bool, usage: Usage) {
        self.person = person
        self.reply = reply
        self.quotaExhausted = quotaExhausted
        self.usage = usage
    }
}

/** A committed draft message and the engine's remaining-money message after it. */
package struct CommitResult: Sendable {
    /** The draft message, now committed with its batch. */
    package let message: ChatMessage
    /** The engine's remaining-money message. */
    package let remaining: ChatMessage

    /** The answer to Simpan. */
    package init(message: ChatMessage, remaining: ChatMessage) {
        self.message = message
        self.remaining = remaining
    }
}

/** A receipt read on the device: `POST /chat/receipts`. Only text leaves the phone. */
package struct ReceiptInput: Hashable, Sendable {
    /** The idempotency key. */
    package let clientId: String
    /** The store's name from the receipt's head. */
    package let storeName: String
    /** When the receipt was printed, else when it was read. */
    package let occurredAt: Date
    /** The printed total, which the items add up to. */
    package let total: Int
    /** The bought items. */
    package let items: [ReceiptItemInput]

    /** A receipt to send. */
    package init(clientId: String, storeName: String, occurredAt: Date, total: Int, items: [ReceiptItemInput]) {
        self.clientId = clientId
        self.storeName = storeName
        self.occurredAt = occurredAt
        self.total = total
        self.items = items
    }
}

/** One item of a receipt with its guessed category. */
package struct ReceiptItemInput: Hashable, Sendable {
    /** The item's name, numbers masked. */
    package let name: String
    /** Whole rupiah. */
    package let amount: Int
    /** The guessed category. */
    package let category: TransactionCategory

    /** An item to send. */
    package init(name: String, amount: Int, category: TransactionCategory) {
        self.name = name
        self.amount = amount
        self.category = category
    }
}

/** A transaction typed into Catat Manual (CAT-04): `POST /transactions`, no AI quota. */
package struct ManualTransactionInput: Hashable, Sendable {
    /** The idempotency key, kept across retries so Coba Lagi never saves twice (CAT-04c). */
    package let clientId: String
    /** Pengeluaran or Pemasukan. */
    package let type: TransactionType
    /** Whole rupiah. */
    package let amount: Int
    /** The chosen tile. */
    package let category: TransactionCategory
    /** The name, or the category's name when left empty. */
    package let name: String
    /** When it happened. */
    package let occurredAt: Date
    /** The optional note. */
    package let note: String?

    /** A manual entry to save. */
    package init(
        clientId: String, type: TransactionType, amount: Int, category: TransactionCategory, name: String,
        occurredAt: Date, note: String?
    ) {
        self.clientId = clientId
        self.type = type
        self.amount = amount
        self.category = category
        self.name = name
        self.occurredAt = occurredAt
        self.note = note
    }
}

/** The saved transaction's id and Kira's `manual_saved` message for the chat. */
package struct ManualSaveResult: Sendable {
    /** The saved transaction's id. */
    package let transactionId: String
    /** Kira's `manual_saved` message. */
    package let message: ChatMessage

    /** The answer to a manual save. */
    package init(transactionId: String, message: ChatMessage) {
        self.transactionId = transactionId
        self.message = message
    }
}
