import Foundation
import Testing

@testable import Domain

@Suite("CommunityGroup")
struct CommunityGroupTests {
    @Test("accepting the rules keeps everything else")
    func acceptingRules() {
        let summary = CommunityGroupSummary(
            id: "a", name: "Lunas Bareng Jakarta", category: .debtFree, platform: .whatsapp, memberCount: 1240,
            summary: "s", icon: .paylater)
        let admin = CommunityAdmin(
            name: "Rani A.", initials: "RA", verifiedSince: CalendarDay(year: 2026, month: 3, day: 1))
        let group = CommunityGroup(
            summary: summary, about: "about", admin: admin, rules: ["1", "2", "3"],
            linkCheckedOn: CalendarDay(year: 2026, month: 10, day: 12), adminUnchanged: true, rulesAccepted: false)
        let accepted = group.acceptingRules()
        #expect(accepted.rulesAccepted && !group.rulesAccepted)
        #expect(accepted.summary == summary && accepted.about == "about" && accepted.admin == admin)
        #expect(accepted.rules == ["1", "2", "3"] && accepted.adminUnchanged)
        #expect(accepted.linkCheckedOn == CalendarDay(year: 2026, month: 10, day: 12))
        #expect(admin.name == "Rani A." && admin.initials == "RA")
    }

    @Test("the rules' version is the backend's, and an invite keeps its link")
    func rulesAndInvite() throws {
        #expect(CommunityRules.version == "community-2026-10-01")
        let url = try #require(URL(string: "https://chat.whatsapp.com/abc"))
        let checked = CalendarDay(year: 2026, month: 10, day: 12)
        let invite = GroupInvite(url: url, platform: .whatsapp, linkCheckedOn: checked)
        #expect(invite.url == url && invite.platform == .whatsapp && invite.linkCheckedOn.day == 12)
    }
}
