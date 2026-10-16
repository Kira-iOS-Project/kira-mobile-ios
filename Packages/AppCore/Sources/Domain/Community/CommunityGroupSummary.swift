/** One verified group on Komunitas (KOM-01): its name, category, platform, members and line. */
package struct CommunityGroupSummary: Identifiable, Hashable, Sendable {
    /** The group's id. */
    package let id: String
    /** "Lunas Bareng Jakarta". */
    package let name: String
    /** Its category. */
    package let category: CommunityCategory
    /** Where it meets. */
    package let platform: CommunityPlatform
    /** Members at the last verification. */
    package let memberCount: Int
    /** One line about it. */
    package let summary: String
    /** Its tile. */
    package let icon: CommunityGroupIcon
    /** Whether it is for learning only ("edukasi saja"), as crypto groups are. */
    package let educationOnly: Bool

    /** A group with every field given. */
    package init(
        id: String, name: String, category: CommunityCategory, platform: CommunityPlatform, memberCount: Int,
        summary: String, icon: CommunityGroupIcon, educationOnly: Bool = false
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.platform = platform
        self.memberCount = memberCount
        self.summary = summary
        self.icon = icon
        self.educationOnly = educationOnly
    }
}

/** Komunitas's directory: the categories to filter by and the groups in the curators' order. */
package struct CommunityDirectory: Hashable, Sendable {
    /** The categories, in the API's order. */
    package let categories: [CommunityCategory]
    /** The active groups, in the curators' order (never by members). */
    package let groups: [CommunityGroupSummary]

    /** A directory of `categories` and `groups`. */
    package init(categories: [CommunityCategory], groups: [CommunityGroupSummary]) {
        self.categories = categories
        self.groups = groups
    }

    /** The groups of `category`, or every group for nil ("Semua"), keeping the curators' order. */
    package func groups(in category: CommunityCategory?) -> [CommunityGroupSummary] {
        guard let category else { return groups }
        return groups.filter { $0.category == category }
    }
}
