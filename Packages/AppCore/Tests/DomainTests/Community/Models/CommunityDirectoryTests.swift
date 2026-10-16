import Testing

@testable import Domain

@Suite("Community directory")
struct CommunityDirectoryTests {
    private let groups = [
        CommunityGroupSummary(
            id: "a", name: "A", category: .debtFree, platform: .whatsapp, memberCount: 1, summary: "s",
            icon: .paylater),
        CommunityGroupSummary(
            id: "b", name: "B", category: .crypto, platform: .discord, memberCount: 2, summary: "s", icon: .crypto,
            educationOnly: true),
        CommunityGroupSummary(
            id: "c", name: "C", category: .debtFree, platform: .telegram, memberCount: 3, summary: "s", icon: .other),
    ]

    @Test("Semua keeps every group; a category keeps its own, in the curators' order")
    func filter() {
        let directory = CommunityDirectory(categories: CommunityCategory.allCases, groups: groups)
        #expect(directory.groups(in: nil).map(\.id) == ["a", "b", "c"])
        #expect(directory.groups(in: .debtFree).map(\.id) == ["a", "c"])
        #expect(directory.groups(in: .stocks).isEmpty)
        #expect(groups[1].educationOnly && !groups[0].educationOnly)
    }

    @Test("the API's spellings, and an unknown icon falls back to the generic tile")
    func vocabulary() {
        #expect(CommunityCategory.allCases.map(\.rawValue) == ["debt_free", "stocks", "crypto", "finance_talk"])
        #expect(CommunityPlatform.allCases.map(\.rawValue) == ["whatsapp", "telegram", "discord"])
        #expect(CommunityGroupIcon(named: "saham") == .stocks)
        #expect(CommunityGroupIcon(named: "gaji") == .salary)
        #expect(CommunityGroupIcon(named: "kripto") == .crypto)
        #expect(CommunityGroupIcon(named: "paylater") == .paylater)
        #expect(CommunityGroupIcon(named: "emas") == .other)
    }
}
