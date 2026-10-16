import Foundation

/** A new chat message with the drafts the device read from it: `POST /chat/messages`. */
package struct OutgoingMessage: Hashable, Sendable {
    /** The idempotency key: the same message sent twice is stored once. */
    package let clientId: String
    package let text: String
    package let inputMethod: InputMethod
    package let voiceSeconds: Int?
    package let parser: DraftParserKind
    package let drafts: [DraftInput]

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
    package let person: ChatMessage
    package let reply: ChatMessage?
    package let quotaExhausted: Bool
    package let usage: Usage

    package init(person: ChatMessage, reply: ChatMessage?, quotaExhausted: Bool, usage: Usage) {
        self.person = person
        self.reply = reply
        self.quotaExhausted = quotaExhausted
        self.usage = usage
    }
}

/** A committed draft message and the engine's remaining-money message after it. */
package struct CommitResult: Sendable {
    package let message: ChatMessage
    package let remaining: ChatMessage

    package init(message: ChatMessage, remaining: ChatMessage) {
        self.message = message
        self.remaining = remaining
    }
}

/** A receipt read on the device: `POST /chat/receipts`. Only text leaves the phone. */
package struct ReceiptInput: Hashable, Sendable {
    package let clientId: String
    package let storeName: String
    package let occurredAt: Date
    package let total: Int
    package let items: [ReceiptItemInput]

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
    package let name: String
    package let amount: Int
    package let category: TransactionCategory

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
    package let type: TransactionType
    package let amount: Int
    package let category: TransactionCategory
    package let name: String
    package let occurredAt: Date
    package let note: String?

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
    package let transactionId: String
    package let message: ChatMessage

    package init(transactionId: String, message: ChatMessage) {
        self.transactionId = transactionId
        self.message = message
    }
}
