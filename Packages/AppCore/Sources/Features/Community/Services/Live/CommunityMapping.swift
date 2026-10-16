import APIClient
import Domain
import Foundation

/** The community routes' answers in the Domain's values. */
extension CommunityDirectory {
    /** The directory `GET /community/groups` returns. */
    init(_ dto: CommunityGroupsDTO) throws {
        self.init(
            categories: try dto.categories.map { try Bridge.value($0) },
            groups: try dto.groups.map(CommunityGroupSummary.init))
    }
}

extension CommunityGroupSummary {
    /** One group; an icon this build does not know gets the generic tile. */
    init(_ dto: CommunityGroupSummaryDTO) throws {
        self.init(
            id: dto.id, name: dto.name, category: try Bridge.value(dto.category),
            platform: try Bridge.value(dto.platform), memberCount: dto.memberCount, summary: dto.summary,
            icon: CommunityGroupIcon(named: dto.icon), educationOnly: dto.educationOnly)
    }
}

extension CommunityGroup {
    /** One group in full; the admin's month (`YYYY-MM`) becomes its first day. */
    init(_ dto: CommunityGroupDTO) throws {
        self.init(
            summary: try CommunityGroupSummary(dto.summary), about: dto.about,
            admin: CommunityAdmin(
                name: dto.adminName, initials: dto.adminInitials,
                verifiedSince: try Bridge.day(dto.adminVerifiedSince + "-01")),
            rules: dto.rules, linkCheckedOn: try dto.linkCheckedOn.map(Bridge.day), adminUnchanged: dto.adminUnchanged,
            rulesAccepted: dto.rulesAccepted)
    }
}

extension GroupInvite {
    /** The invite to open; a link that is not a URL is a problem without a code. */
    init(_ dto: CommunityGroupJoinDTO) throws {
        guard let url = URL(string: dto.inviteUrl), url.scheme == "https" else { throw AppProblem() }
        self.init(url: url, platform: try Bridge.value(dto.platform), linkCheckedOn: try Bridge.day(dto.linkCheckedOn))
    }
}
