import Foundation

/** What the community routes answer (KOM-01 to KOM-05): groups, one group, the invite. */

/** A category of the directory. */
package enum CommunityCategoryDTO: String, CaseIterable, Sendable {
    /** Bebas Hutang. */
    case debtFree = "debt_free"
    /** Saham. */
    case stocks
    /** Web3/Kripto. */
    case crypto
    /** Diskusi Keuangan. */
    case financeTalk = "finance_talk"
}

/** Where a group meets. */
package enum CommunityPlatformDTO: String, CaseIterable, Sendable {
    /** WhatsApp. */
    case whatsapp
    /** Telegram. */
    case telegram
    /** Discord. */
    case discord
}

/** Why a group is reported. */
package enum GroupReportReasonDTO: String, CaseIterable, Sendable {
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
    /** Lainnya. */
    case other
}

/** One group as the directory lists it. */
package struct CommunityGroupSummaryDTO: Hashable, Sendable {
    /** Its id. */
    package let id: String
    /** Its name. */
    package let name: String
    /** Its category. */
    package let category: CommunityCategoryDTO
    /** Where it meets. */
    package let platform: CommunityPlatformDTO
    /** Members at the last verification. */
    package let memberCount: Int
    /** One line about it. */
    package let summary: String
    /** The design system's category icon name ("paylater", "saham"). */
    package let icon: String
    /** Whether it is for learning only. */
    package let educationOnly: Bool

    init(_ body: Components.Schemas.CommunityGroupSummary) throws {
        id = body.id
        name = body.name
        category = try bridged(body.category)
        platform = try bridged(body.platform)
        memberCount = body.memberCount
        summary = body.summary
        icon = body.icon
        educationOnly = body.educationOnly
    }
}

/** The directory: its categories and the active groups in the curators' order. */
package struct CommunityGroupsDTO: Hashable, Sendable {
    /** The categories, in order. */
    package let categories: [CommunityCategoryDTO]
    /** The groups, in order. */
    package let groups: [CommunityGroupSummaryDTO]

    init(_ body: Components.Schemas.CommunityGroups) throws {
        categories = try body.categories.map { try bridged($0.key) }
        groups = try body.groups.map(CommunityGroupSummaryDTO.init)
    }
}

/** One group in full. */
package struct CommunityGroupDTO: Hashable, Sendable {
    /** The group as the directory lists it. */
    package let summary: CommunityGroupSummaryDTO
    /** What the group is for. */
    package let about: String
    /** The admin's shown name. */
    package let adminName: String
    /** The admin's initials. */
    package let adminInitials: String
    /** The month the admin was verified (`YYYY-MM`). */
    package let adminVerifiedSince: String
    /** The three main rules. */
    package let rules: [String]
    /** The day the link was last checked (`YYYY-MM-DD`). */
    package let linkCheckedOn: String
    /** Whether the admin is still the one verified. */
    package let adminUnchanged: Bool
    /** Whether the current community rules are accepted. */
    package let rulesAccepted: Bool

    init(_ body: Components.Schemas.CommunityGroup) throws {
        summary = try CommunityGroupSummaryDTO(body.value1)
        about = body.value2.about
        adminName = body.value2.admin.name
        adminInitials = body.value2.admin.initials
        adminVerifiedSince = body.value2.admin.verifiedSince
        rules = body.value2.rules
        linkCheckedOn = body.value2.linkCheckedOn
        adminUnchanged = body.value2.adminUnchanged
        rulesAccepted = body.value2.rulesAccepted
    }
}

/** The invite to open outside Kira. */
package struct CommunityGroupJoinDTO: Hashable, Sendable {
    /** The invite link. */
    package let inviteUrl: String
    /** Where it leads. */
    package let platform: CommunityPlatformDTO
    /** The day the link was last checked (`YYYY-MM-DD`). */
    package let linkCheckedOn: String

    init(_ body: Components.Schemas.CommunityGroupJoin) throws {
        inviteUrl = body.inviteUrl
        platform = try bridged(body.platform)
        linkCheckedOn = body.linkCheckedOn
    }
}
