import Foundation

/**
 Aturan Komunitas Kira (KOM-03): five rules the person accepts before joining any group. The
 acceptance is kept per account with the rules' version; a new version asks again.
 */
package enum CommunityRules {
    /** The rules in force, the backend's `COMMUNITY_RULES_VERSION`. */
    package static let version = "community-2026-10-01"
}

/** What `POST /community/groups/{id}/join` answers: the invite to open outside Kira. */
package struct GroupInvite: Hashable, Sendable {
    /** The group's invite link (`https://chat.whatsapp.com/…`, `https://t.me/…`, `https://discord.gg/…`). */
    package let url: URL
    /** Where it leads. */
    package let platform: CommunityPlatform
    /** The day the link was last checked. */
    package let linkCheckedOn: CalendarDay

    /** An invite with every field given. */
    package init(url: URL, platform: CommunityPlatform, linkCheckedOn: CalendarDay) {
        self.url = url
        self.platform = platform
        self.linkCheckedOn = linkCheckedOn
    }
}
