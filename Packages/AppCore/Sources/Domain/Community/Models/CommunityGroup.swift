/**
 Detail Grup (KOM-02): one group with its admin, what it is for, its three main rules, when its
 link was last checked, and whether the person has accepted the current community rules.
 */
package struct CommunityGroup: Hashable, Sendable {
    /** The group as the directory lists it. */
    package let summary: CommunityGroupSummary
    /** "Tentang Grup". */
    package let about: String
    /** The verified admin. */
    package let admin: CommunityAdmin
    /** "Aturan Utama": three rules. */
    package let rules: [String]
    /** The day the moderation team last checked the invite link. */
    package let linkCheckedOn: CalendarDay?
    /** Whether the admin is still the one verified ("admin masih sama"). */
    package let adminUnchanged: Bool
    /** Whether the person accepted the current version of the community rules. */
    package let rulesAccepted: Bool

    /** A group with every field given. */
    package init(
        summary: CommunityGroupSummary, about: String, admin: CommunityAdmin, rules: [String],
        linkCheckedOn: CalendarDay?, adminUnchanged: Bool, rulesAccepted: Bool
    ) {
        self.summary = summary
        self.about = about
        self.admin = admin
        self.rules = rules
        self.linkCheckedOn = linkCheckedOn
        self.adminUnchanged = adminUnchanged
        self.rulesAccepted = rulesAccepted
    }

    /** The same group once the person has accepted the current rules. */
    package func acceptingRules() -> CommunityGroup {
        CommunityGroup(
            summary: summary, about: about, admin: admin, rules: rules, linkCheckedOn: linkCheckedOn,
            adminUnchanged: adminUnchanged, rulesAccepted: true)
    }
}

/** A group's verified admin ("Rani A.", "Admin terverifikasi sejak Maret 2026"). */
package struct CommunityAdmin: Hashable, Sendable {
    /** The admin's shown name. */
    package let name: String
    /** The initials on the avatar ("RA"). */
    package let initials: String
    /** The month the admin was first verified: its first day. */
    package let verifiedSince: CalendarDay

    /** An admin with every field given. */
    package init(name: String, initials: String, verifiedSince: CalendarDay) {
        self.name = name
        self.initials = initials
        self.verifiedSince = verifiedSince
    }
}
