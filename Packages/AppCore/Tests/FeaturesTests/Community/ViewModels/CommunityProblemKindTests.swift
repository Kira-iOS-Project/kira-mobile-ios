import APIClient
import Testing

@testable import Features

@Suite("CommunityProblemKind")
struct CommunityProblemKindTests {
    @Test("every problem code has its kind; only those sending again can fix offer Coba Lagi")
    func kinds() {
        #expect(CommunityProblemKind(.communityGroupNotFound) == .groupGone)
        #expect(CommunityProblemKind(.communityLinkUnavailable) == .linkUnavailable)
        #expect(CommunityProblemKind(.communityRulesNotAccepted) == .rulesNotAccepted)
        #expect(CommunityProblemKind(.communityReportDuplicate) == .reportDuplicate)
        #expect(CommunityProblemKind(.validationFailed) == .refused)
        let others = ProblemCode.allCases.filter { CommunityProblemKind($0) == .other }
        #expect(others.count == ProblemCode.allCases.count - 5)
        #expect(CommunityProblemKind(nil) == .other)
        #expect([CommunityProblemKind.rulesNotAccepted, .other].allSatisfy(\.allowsRetry))
        let final: [CommunityProblemKind] = [.groupGone, .linkUnavailable, .reportDuplicate, .refused]
        #expect(!final.contains(where: \.allowsRetry))
        #expect(CommunityFailure.connection.kind == nil)
    }
}
