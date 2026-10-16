import APIClient
import Domain
import Foundation

@testable import Features

/**
 The API boundary of Komunitas, replaced for the model tests: each call answers with the next
 result its queue holds (nil succeeds; the default once the queue is empty) and is recorded.
 */
actor FakeCommunityService: CommunityService {
    /** A call the screens made. */
    enum Call: Equatable {
        case directory
        case group(String)
        case acceptRules(String)
        case join(String)
        case report(String, GroupReportReason, String?)
    }

    static let summary = CommunityGroupSummary(
        id: "g-1", name: "Lunas Bareng Jakarta", category: .debtFree, platform: .whatsapp, memberCount: 1240,
        summary: "Saling dukung melunasi utang lewat jalur resmi.", icon: .paylater)

    static func group(rulesAccepted: Bool) -> CommunityGroup {
        CommunityGroup(
            summary: summary, about: "about",
            admin: CommunityAdmin(
                name: "Rani A.", initials: "RA", verifiedSince: CalendarDay(year: 2026, month: 3, day: 1)),
            rules: ["1", "2", "3"], linkCheckedOn: CalendarDay(year: 2026, month: 10, day: 12), adminUnchanged: true,
            rulesAccepted: rulesAccepted)
    }

    static let invite = GroupInvite(
        url: URL(string: "https://chat.whatsapp.com/abc") ?? URL(filePath: "/"), platform: .whatsapp,
        linkCheckedOn: CalendarDay(year: 2026, month: 10, day: 12))

    private(set) var calls: [Call] = []
    private var failures: [String: [(any Error)?]]
    private let directoryValue: CommunityDirectory
    private let rulesAccepted: Bool

    init(
        directory: CommunityDirectory = CommunityDirectory(categories: CommunityCategory.allCases, groups: [summary]),
        rulesAccepted: Bool = false, failures: [String: [(any Error)?]] = [:]
    ) {
        directoryValue = directory
        self.rulesAccepted = rulesAccepted
        self.failures = failures
    }

    func directory() throws -> CommunityDirectory {
        try record(.directory, "directory")
        return directoryValue
    }

    func group(id: String) throws -> CommunityGroup {
        try record(.group(id), "group")
        return Self.group(rulesAccepted: rulesAccepted)
    }

    func acceptRules(version: String) throws { try record(.acceptRules(version), "acceptRules") }

    func join(groupID: String) throws -> GroupInvite {
        try record(.join(groupID), "join")
        return Self.invite
    }

    func report(groupID: String, reason: GroupReportReason, story: String?) throws {
        try record(.report(groupID, reason, story), "report")
    }

    private func record(_ call: Call, _ name: String) throws {
        calls.append(call)
        if var queue = failures[name], !queue.isEmpty {
            let error = queue.removeFirst()
            failures[name] = queue
            if let error { throw error }
        }
    }
}

/** A problem with `code` under this API's base. */
func communityProblem(_ code: ProblemCode) -> AppProblem {
    AppProblem(type: AppProblem.typeBase + code.rawValue, code: code.rawValue, requestId: "r-1")
}
