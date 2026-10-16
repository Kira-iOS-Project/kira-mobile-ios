import Foundation

/**
 Laporkan Grup (KOM-05, KOM-05d): one reason, and a short story that is optional, or required for
 "Lainnya". The reporter's identity is never shared with the group's admins.
 */

/** Why a group is reported: the backend's `reason` values. */
package enum GroupReportReason: String, CaseIterable, Hashable, Sendable {
    /** Ajakan Gagal Bayar. */
    case defaultInvite = "default_invite"
    /** Janji Untung Pasti. */
    case guaranteedProfit = "guaranteed_profit"
    /** Penipuan atau Minta Transfer. */
    case scam
    /** Jual Data atau Joki. */
    case dataOrJockey = "data_or_jockey"
    /** Konten Tidak Pantas. */
    case inappropriate
    /** Lainnya: the story is then required. */
    case other
}

/** A report as filled in, and whether it may be sent. */
package struct GroupReport: Hashable, Sendable {
    /** The longest story the API takes. */
    package static let storyLimit = 500

    /** The reason chosen, nil until one is. */
    package var reason: GroupReportReason?
    /** The story as typed. */
    package var story: String

    /** A report with nothing chosen yet. */
    package init(reason: GroupReportReason? = nil, story: String = "") {
        self.reason = reason
        self.story = story
    }

    /** The story without spaces around it, nil when blank: what is sent. */
    package var trimmedStory: String? {
        let trimmed = story.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    /** Whether the story is required: the reason is "Lainnya". */
    package var requiresStory: Bool { reason == .other }

    /** Whether "Kirim Laporan" may be tapped: a reason, a story when required, within 500 characters. */
    package var canSend: Bool {
        guard reason != nil, story.count <= Self.storyLimit else { return false }
        return !requiresStory || trimmedStory != nil
    }
}
