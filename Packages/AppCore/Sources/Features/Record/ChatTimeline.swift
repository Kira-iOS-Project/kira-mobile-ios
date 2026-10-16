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

    /** The message id, or the separator's own id. */
    package var id: String {
        switch self {
        case .separator(let id, _): id
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

    /** The rows of `messages` (oldest first); `undoable` holds the messages Urungkan may still undo. */
    package static func rows(of messages: [ChatMessage], undoable: Set<String>) -> [ChatRow] {
        var byId: [String: ChatMessage] = [:]
        for message in messages { byId[message.id] = message }
        var rows: [ChatRow] = []
        var previous: Date?
        for message in messages {
            if opensStretch(message.createdAt, after: previous) {
                rows.append(.separator(id: "separator-\(message.id)", date: message.createdAt))
            }
            previous = message.createdAt
            rows.append(row(of: message, source: message.replyToId.flatMap { byId[$0] }, undoable: undoable))
        }
        return rows
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
