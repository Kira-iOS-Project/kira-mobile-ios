import Foundation

/**
 One line Kira Peduli adds to the Catat chat (SinyalKrisis, CheckInChat). It lives on this device
 only: the person's crisis message is never sent as a chat message, never read for transactions and
 never stored, and Kira's lines are the team's fixed templates.
 */
package struct CareChatEntry: Identifiable, Equatable, Sendable {
    /** What the line shows. */
    package enum Kind: Equatable, Sendable {
        /** The message in which a crisis signal was found, as the person wrote it. */
        case personText(String)
        /** A quick reply the person tapped. */
        case personChoice(CareChoice)
        /** Kira's fixed reply to a crisis signal, its quick replies until one is chosen, and Lihat Bantuan. */
        case crisisReply(isAnswered: Bool)
        /** The check-in greeting the person asked for, with its quick replies until one is chosen. */
        case checkInGreeting(name: String, isAnswered: Bool)
        /** Kira's reply to Sedikit Lebih Baik, with the Mode Darurat Utang card. */
        case checkInBetter
    }

    /** The line's id. */
    package let id: String
    /** When it was added, for its place among the chat's messages. */
    package let createdAt: Date
    /** What it shows. */
    package var kind: Kind

    /** A line added at `createdAt`. */
    package init(id: String, createdAt: Date, kind: Kind) {
        self.id = id
        self.createdAt = createdAt
        self.kind = kind
    }
}

/** The quick replies of SinyalKrisis and CheckInChat. */
package enum CareChoice: Sendable {
    /** Aku Aman: Kira offers the check-in. */
    case safe
    /** Aku Tidak Aman: the help sheet. */
    case unsafe
    /** Mau Cerita Dulu: back to the composer. */
    case talkFirst
    /** Sedikit Lebih Baik: Kira's reply and Mode Darurat Utang. */
    case better
    /** Masih Berat: the help sheet again. */
    case stillHeavy
    /** Mau Bahas Utangnya: Mode Darurat Utang. */
    case talkAboutDebt

    /** The quick replies under a crisis reply, in the board's order. */
    package static let crisis: [Self] = [.safe, .unsafe, .talkFirst]
    /** The quick replies under a check-in greeting, in the board's order. */
    package static let checkIn: [Self] = [.better, .stillHeavy, .talkAboutDebt]
}
