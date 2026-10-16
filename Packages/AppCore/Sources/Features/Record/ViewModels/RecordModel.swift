import APIClient
import Domain
import Foundation
import Observation

/**
 Catat (CAT-01, CAT-03, CAT-03b, CAT-09): the two-way chat in which every reply names the message
 it came from, drafts wait for Simpan, saved transactions can be undone for ten seconds, and the
 engine's remaining money follows each save. It opens the edit sheet, Catat Manual, Scan Struk,
 the voice panel and the quota sheet. Its extensions hold the chat actions and those openings.
 */
@MainActor
@Observable
package final class RecordModel {
    /** How long Urungkan stays after a save (CAT-03), without a countdown. */
    static let undoSeconds = 10.0

    /** Loading, the loaded profile, or the problem that stopped the load. */
    package internal(set) var phase: ScreenPhase<RecordProfile> = .loading
    /** The chat's messages, oldest first. */
    package internal(set) var messages: [ChatMessage] = []
    /** The quotas after the latest answer, else the profile's. */
    package internal(set) var usage: Usage?
    /** The composer's text. */
    package var composerText = ""
    /** Whether a message is on its way. */
    package internal(set) var isSending = false
    /** Whether an older page is loading. */
    package internal(set) var isLoadingOlder = false
    /** The committed messages Urungkan may still undo. */
    package internal(set) var undoable: Set<String> = []
    /** The quota sheet, when a quota ran out. */
    package var quotaSheet: QuotaSheet?
    /** Why the last chat action did not go through. */
    package var failure: RecordFailure?
    /** "Kira AI" is off in Data & Privasi: chat, receipts and voice wait; Catat Manual works. */
    package var showsAIOff = false
    /** Grows each time Lanjut Chat asks the view to focus the composer (CAT-03b). */
    package internal(set) var composerFocusRequests = 0
    /** Ubah Transaksi, while it is open. */
    package var editor: DraftEditModel?
    /** Catat Manual, while it is open. */
    package var manualEntry: ManualEntryModel?
    /** Scan Struk, while it is open. */
    package var scanner: ReceiptScanModel?
    /** The voice panel, while it is open. */
    package internal(set) var voice: VoiceInputModel?
    /** Where Catat sends the person outside itself: Riwayat, Paket, Kira Peduli. */
    package var onOpen: (AppRoute) -> Void = { _ in }
    /** What Catat reaches outside itself for; the scanner's view draws the camera's preview from it. */
    package let dependencies: RecordDependencies
    var nextCursor: String?
    /** The remaining-money message each commit added, removed again by Urungkan. */
    var remainingIds: [String: String] = [:]
    /** The id of a message that failed to send, reused while its text is unchanged. */
    var retry: (text: String, clientId: String)?

    /** Catat with what it reaches outside itself for. */
    package init(dependencies: RecordDependencies) {
        self.dependencies = dependencies
    }

    /** The loaded profile, or nil. */
    package var profile: RecordProfile? { phase.value }

    /** The chat's rows, oldest first. */
    package var rows: [ChatRow] { ChatTimeline.rows(of: messages, undoable: undoable) }

    /** Whether a page before the oldest message is waiting. */
    package var hasOlder: Bool { nextCursor != nil }

    /** The newest page of the chat and the profile, together. */
    package func load() async {
        phase = .loading
        do {
            async let profile = dependencies.service.profile()
            async let page = dependencies.service.messages(before: nil)
            let (loadedProfile, loadedPage) = try await (profile, page)
            messages = loadedPage.items
            nextCursor = loadedPage.nextCursor
            usage = loadedProfile.usage
            phase = .loaded(loadedProfile)
        } catch {
            phase = .failed(error as? AppProblem ?? AppProblem())
        }
    }

    /** The page before the oldest message, when the person scrolls to the top. */
    package func loadOlder() async {
        guard let cursor = nextCursor, !isLoadingOlder else { return }
        isLoadingOlder = true
        defer { isLoadingOlder = false }
        do {
            let page = try await dependencies.service.messages(before: cursor)
            let known = Set(messages.map(\.id))
            messages = page.items.filter { !known.contains($0.id) } + messages
            nextCursor = page.nextCursor
        } catch {
            /** error ignored: the cursor stays, so the next scroll to the top asks again */
        }
    }

    /** Puts `message` in its place, or at the end when it is new. */
    func replace(_ message: ChatMessage) {
        if let index = messages.firstIndex(where: { $0.id == message.id }) {
            messages[index] = message
        } else {
            messages.append(message)
        }
    }

    /** The time of the person's message `message` answers, else its own. */
    package func sourceTime(of message: ChatMessage) -> Date {
        message.replyToId.flatMap { id in messages.first { $0.id == id }?.createdAt } ?? message.createdAt
    }
}

/** The numbers of the quota sheet (KuotaAI). */
package struct QuotaSheet: Equatable, Sendable {
    /** Which quota ran out: chat messages (the board), receipts (CAT-05) or voice seconds. */
    package enum Kind: Equatable, Sendable {
        /** Chat messages, receipts or voice seconds. */
        case aiMessages, receipts, voice
    }

    /** Which quota ran out. */
    package let kind: Kind
    /** Its used and limit. */
    package let counter: UsageMeter
    /** The day it fills again. */
    package let resetsOn: Date
    /** The plan, for "Paket Kira Gratis". */
    package let plan: PlanID
    /** Today, for the month in "Paket Kira Gratis · Oktober". */
    package let today: Date
}
