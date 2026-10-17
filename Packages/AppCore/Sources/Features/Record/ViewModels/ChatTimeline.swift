import Domain
import Foundation

/** One line of the Catat chat, in the order the board draws them. */
package enum ChatRow: Identifiable, Equatable, Sendable {
    /** The centred "15 Oktober 2026 · 12.41 WIB" above a new stretch of the chat. */
    case separator(id: String, date: Date)
    /** The person's text, or the photo of a receipt they scanned. */
    case person(ChatMessage)
    /** Kira's drafts waiting for Simpan, with the message they were read from. */
    case drafts(ChatMessage, source: ChatMessage?)
    /** Kira's saved transactions; Urungkan shows for ten seconds after the save. */
    case saved(ChatMessage, source: ChatMessage?, canUndo: Bool)
    /** Drafts the person removed one by one until none were left. */
    case discarded(ChatMessage)
    /** The engine's remaining money for the period ("Dihitung mesin"). */
    case remaining(ChatMessage)
    /** A transaction saved from Catat Manual. */
    case manualSaved(ChatMessage)
    /** A reply to a message without an amount Kira could read. */
    case noDrafts(ChatMessage)
    /** A line of Kira Peduli, kept on this device only (PED-02, PED-06). */
    case care(CareChatEntry)

    /** The message id, or the separator's own id. */
    package var id: String {
        switch self {
        case .separator(let id, _): id
        case .care(let entry): entry.id
        case .person(let message), .drafts(let message, _), .saved(let message, _, _), .discarded(let message),
            .remaining(let message), .manualSaved(let message), .noDrafts(let message):
            message.id
        }
    }
}

/** Builds the chat's rows from its messages. */
package enum ChatTimeline {
    /** A pause this long, or a new day in WIB, opens a new stretch with its own time. */
    static let pause: TimeInterval = 10 * 60

    /** Jakarta's calendar: Catat's days and times are WIB wherever the phone is. */
    static let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        if let jakarta = TimeZone(identifier: "Asia/Jakarta") { calendar.timeZone = jakarta }
        return calendar
    }()

    /**
     The rows of `messages` (oldest first) with Kira Peduli's `care` lines in their place by time;
     `undoable` holds the messages Urungkan may still undo.
     */
    package static func rows(
        of messages: [ChatMessage], undoable: Set<String>, care: [CareChatEntry] = []
    ) -> [ChatRow] {
        var byId: [String: ChatMessage] = [:]
        for message in messages { byId[message.id] = message }
        var rows: [ChatRow] = []
        var previous: Date?
        for (date, row) in merged(messages, care, byId: byId, undoable: undoable) {
            if opensStretch(date, after: previous) {
                rows.append(.separator(id: "separator-\(row.id)", date: date))
            }
            previous = date
            rows.append(row)
        }
        return rows
    }

    /** Both lists in one, by time; at the same time the message comes first. */
    private static func merged(
        _ messages: [ChatMessage], _ care: [CareChatEntry], byId: [String: ChatMessage], undoable: Set<String>
    ) -> [(Date, ChatRow)] {
        let chat = messages.map { message in
            (message.createdAt, row(of: message, source: message.replyToId.flatMap { byId[$0] }, undoable: undoable))
        }
        var lines = ArraySlice(care)
        var result: [(Date, ChatRow)] = []
        for item in chat {
            while let line = lines.first, line.createdAt < item.0 {
                result.append((line.createdAt, .care(line)))
                lines.removeFirst()
            }
            result.append(item)
        }
        return result + lines.map { ($0.createdAt, .care($0)) }
    }

    private static func opensStretch(_ date: Date, after previous: Date?) -> Bool {
        guard let previous else { return true }
        return date.timeIntervalSince(previous) >= pause || !calendar.isDate(date, inSameDayAs: previous)
    }

    private static func row(of message: ChatMessage, source: ChatMessage?, undoable: Set<String>) -> ChatRow {
        switch message.kind {
        case .personText, .personReceipt:
            return .person(message)
        case .drafts:
            switch message.draftStatus {
            case .committed: return .saved(message, source: source, canUndo: undoable.contains(message.id))
            case .discarded: return .discarded(message)
            case .pending, nil: return .drafts(message, source: source)
            }
        case .remaining:
            return .remaining(message)
        case .manualSaved:
            return .manualSaved(message)
        case .noDrafts:
            return .noDrafts(message)
        }
    }
}
