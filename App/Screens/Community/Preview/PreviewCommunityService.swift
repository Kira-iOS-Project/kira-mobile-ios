/**
 Komunitas's service before the API answers: the four groups of the Komunitas board, Lunas Bareng
 Jakarta's detail from Detail Grup (and the same shape for the others), after a short pause.
 Joining needs the rules first, as on the server. No group has a verified link yet (the curation
 team gives them), so joining answers 409 COMMUNITY_LINK_UNAVAILABLE and Detail Grup has no "Link
 dicek" line; with `linksVerified` a join opens the platform's own address, never an invented
 invite. Every report is sent, or none when `reportsFail` (the connection drops).
 */
import APIClient
import Domain
import Features
import Foundation

actor PreviewCommunityService: CommunityService {
    private var rulesAccepted = false
    private let linksVerified: Bool
    private let reportsFail: Bool

    init(linksVerified: Bool = false, reportsFail: Bool = false) {
        self.linksVerified = linksVerified
        self.reportsFail = reportsFail
    }

    func directory() async throws -> CommunityDirectory {
        try await pause()
        return CommunityDirectory(categories: CommunityCategory.allCases, groups: Self.groups)
    }

    func group(id: String) async throws -> CommunityGroup {
        try await pause()
        let summary = Self.groups.first { $0.id == id } ?? Self.groups[0]
        return CommunityGroup(
            summary: summary, about: Self.about[summary.id] ?? summary.summary,
            admin: CommunityAdmin(
                name: "Rani A.", initials: "RA", verifiedSince: CalendarDay(year: 2026, month: 3, day: 1)),
            rules: ["Tanpa Ajakan Gagal Bayar", "Tanpa Jual-Beli Data atau Joki", "Jaga Privasi Sesama Anggota"],
            linkCheckedOn: linksVerified ? Self.checkedOn : nil, adminUnchanged: linksVerified,
            rulesAccepted: rulesAccepted)
    }

    func acceptRules(version _: String) async throws {
        try await pause()
        rulesAccepted = true
    }

    func join(groupID: String) async throws -> GroupInvite {
        try await pause()
        guard linksVerified else { throw AppProblem(code: "COMMUNITY_LINK_UNAVAILABLE") }
        let platform = Self.groups.first { $0.id == groupID }?.platform ?? .whatsapp
        let url = Self.platformHome[platform] ?? URL(filePath: "/")
        return GroupInvite(url: url, platform: platform, linkCheckedOn: Self.checkedOn)
    }

    /** The day the verified links were checked. */
    private static let checkedOn = CalendarDay(year: 2026, month: 10, day: 12)

    /** Each platform's own address, standing in for an invite the team has not given yet. */
    private static let platformHome: [CommunityPlatform: URL] = [
        .whatsapp: URL(string: "https://www.whatsapp.com/"), .telegram: URL(string: "https://telegram.org/"),
        .discord: URL(string: "https://discord.com/"),
    ].compactMapValues { $0 }

    func report(groupID _: String, reason _: GroupReportReason, story _: String?) async throws {
        try await pause()
        if reportsFail { throw URLError(.notConnectedToInternet) }
    }

    private func pause() async throws {
        try await Task.sleep(for: .milliseconds(300))
    }

    /** Komunitas's four groups, in the board's order. */
    static let groups = [
        CommunityGroupSummary(
            id: "lunas-bareng-jakarta", name: "Lunas Bareng Jakarta", category: .debtFree, platform: .whatsapp,
            memberCount: 1240, summary: "Saling dukung melunasi utang lewat jalur resmi.", icon: .paylater),
        CommunityGroupSummary(
            id: "belajar-saham-dari-nol", name: "Belajar Saham dari Nol", category: .stocks, platform: .telegram,
            memberCount: 3810, summary: "Dasar saham pelan-pelan, tanpa sinyal beli.", icon: .stocks),
        CommunityGroupSummary(
            id: "kripto-aman-101", name: "Kripto Aman 101", category: .crypto, platform: .discord, memberCount: 2050,
            summary: "Kenali risiko dan modus penipuan kripto.", icon: .crypto, educationOnly: true),
        CommunityGroupSummary(
            id: "ngobrol-gaji-pertama", name: "Ngobrol Gaji Pertama", category: .financeTalk, platform: .whatsapp,
            memberCount: 860, summary: "Ngobrol santai soal gaji pertama dan anggaran.", icon: .salary),
    ]

    private static let about = [
        "lunas-bareng-jakarta":
            "Saling dukung melunasi utang lewat jalur resmi dan berbagi naskah negosiasi, tanpa ajakan gagal bayar."
    ]
}
