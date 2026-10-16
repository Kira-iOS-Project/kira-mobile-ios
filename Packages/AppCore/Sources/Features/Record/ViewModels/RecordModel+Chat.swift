import Domain
import Foundation

/** Catat's chat actions: send, Simpan, Urungkan, the pencil and Lanjut Chat. */
extension RecordModel {
    /** The send button: the composer's text as a typed message. */
    package func send() async {
        await send(composerText, method: .keyboard, voiceSeconds: nil)
    }

    /**
     Answers a crisis signal on the device, or reads the drafts on the device, then sends the text
     with them. The message is kept even when the month's AI messages are used up: the quota sheet
     then shows instead of a reply (CAT-09).
     */
    func send(_ rawText: String, method: InputMethod, voiceSeconds: Int?) async {
        let text = rawText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, !isSending, let profile else { return }
        isSending = true
        defer { isSending = false }
        /** A crisis signal is answered on the device: the message is never sent or read (PED-02). */
        if await care.intercept(text, allowsModel: profile.aiEnabled) {
            if method == .keyboard { composerText = "" }
            return
        }
        guard profile.aiEnabled else {
            showsAIOff = true
            return
        }
        if method == .keyboard { composerText = "" }
        let clientId = retry.flatMap { $0.text == text ? $0.clientId : nil } ?? dependencies.makeId()
        let read = await dependencies.reader.read(text, at: dependencies.clock.now)
        let outgoing = OutgoingMessage(
            clientId: clientId, text: text, inputMethod: method, voiceSeconds: voiceSeconds, parser: read.parser,
            drafts: read.drafts)
        do {
            apply(try await dependencies.service.send(outgoing), quota: method == .voice ? .voice : .aiMessages)
            retry = nil
        } catch {
            retry = (text, clientId)
            if method == .keyboard, composerText.isEmpty { composerText = text }
            fail(.send(text, method, voiceSeconds), error)
        }
    }

    /** Shows a sent message, its reply, and the quota sheet when the quota ran out. */
    func apply(_ result: SendResult, quota: QuotaSheet.Kind) {
        replace(result.person)
        if let reply = result.reply { replace(reply) }
        usage = result.usage
        if result.quotaExhausted { quotaSheet = sheet(for: quota) }
    }

    /** Simpan N Transaksi: the drafts become transactions, the engine's remaining money follows. */
    package func save(_ message: ChatMessage) async {
        guard committing.insert(message.id).inserted else { return }
        defer { committing.remove(message.id) }
        do {
            let result = try await dependencies.service.commit(messageId: message.id)
            replace(result.message)
            replace(result.remaining)
            remainingIds[message.id] = result.remaining.id
            undoable.insert(message.id)
            let clock = dependencies.clock
            Task { [weak self] in
                try? await clock.sleep(seconds: Self.undoSeconds)
                self?.undoable.remove(message.id)
            }
        } catch {
            fail(.save(message), error)
        }
    }

    /** Urungkan: the transactions are deleted and the drafts wait again. */
    package func undo(_ message: ChatMessage) async {
        guard let batchId = message.batchId, undoable.contains(message.id) else { return }
        guard committing.insert(message.id).inserted else { return }
        defer { committing.remove(message.id) }
        do {
            replace(try await dependencies.service.undo(batchId: batchId))
            undoable.remove(message.id)
            if let remainingId = remainingIds.removeValue(forKey: message.id) {
                messages.removeAll { $0.id == remainingId }
            }
        } catch {
            fail(.undo(message), error)
        }
    }

    /** Coba Lagi on the failure dialog: the chat action that failed runs again. */
    package func retryFailed() async {
        guard let action = failedAction else { return }
        failedAction = nil
        switch action {
        case .send(let text, let method, let voiceSeconds): await send(text, method: method, voiceSeconds: voiceSeconds)
        case .save(let message): await save(message)
        case .undo(let message): await undo(message)
        }
    }

    /** A chat action failed: the failure dialog, or the AI-off notice when the server says Kira AI is off. */
    private func fail(_ action: ChatAction, _ error: any Error) {
        let failure = RecordFailure(error)
        guard !failure.turnsAIOff else { return aiTurnedOff() }
        failedAction = action
        self.failure = failure
    }

    /** The pencil of one draft: Ubah Transaksi (CAT-02). */
    package func edit(_ item: DraftItem, in message: ChatMessage) {
        editor = DraftEditModel(
            item: item, in: message, sourceTime: sourceTime(of: message), service: dependencies.service,
            onUpdated: { [weak self] updated in self?.replace(updated) })
    }

    /** Lanjut Chat: back to the composer, the drafts stay (CAT-03b). */
    package func continueChat() {
        composerFocusRequests += 1
    }

    /** The quota sheet for `kind`, from the latest quotas. */
    func sheet(for kind: QuotaSheet.Kind) -> QuotaSheet? {
        guard let profile, let usage else { return nil }
        let counter: UsageMeter
        switch kind {
        case .aiMessages: counter = usage.aiMessages
        case .receipts: counter = usage.receipts
        case .voice: counter = usage.voiceSeconds
        }
        return QuotaSheet(
            kind: kind, counter: counter, resetsOn: usage.resetsOn.date, plan: profile.plan,
            today: dependencies.clock.now)
    }
}

/** A chat action that can fail and be tried again. */
enum ChatAction {
    /** Sending a message: its text, how it was entered, and the recording's length. */
    case send(String, InputMethod, Int?)
    /** Simpan N Transaksi. */
    case save(ChatMessage)
    /** Urungkan. */
    case undo(ChatMessage)
}
