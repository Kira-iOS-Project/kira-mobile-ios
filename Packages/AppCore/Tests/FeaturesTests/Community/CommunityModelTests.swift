import APIClient
import Domain
import Testing

@testable import Features

@MainActor
@Suite("CommunityModel")
struct CommunityModelTests {
    @Test("loads the directory, and a chip filters it without a request")
    func loadsAndFilters() async {
        let service = FakeCommunityService()
        let model = CommunityModel(service: service)
        #expect(model.groups.isEmpty && model.categories.isEmpty)
        await model.load()
        #expect(model.groups.map(\.id) == ["g-1"])
        #expect(model.categories == CommunityCategory.allCases)
        model.select(.stocks)
        #expect(model.category == .stocks && model.groups.isEmpty)
        model.select(nil)
        #expect(model.groups.count == 1)
        #expect(await service.calls == [.directory])
    }

    @Test("no active group is empty")
    func empty() async {
        let model = CommunityModel(service: FakeCommunityService(directory: CommunityDirectory(categories: [], groups: [])))
        await model.load()
        guard case .empty = model.phase else { Issue.record("not empty"); return }
    }

    @Test("offline shows the generic problem, and Coba Lagi loads; a refusal shows its own problem")
    func failures() async {
        let offline = CommunityModel(service: FakeCommunityService(failures: ["directory": [FakeCommunityService.Offline()]]))
        await offline.load()
        #expect(offline.phase.problem == AppProblem())
        await offline.load()
        #expect(offline.groups.count == 1)
        let refused = CommunityModel(
            service: FakeCommunityService(failures: ["directory": [communityProblem(.authUnauthenticated)]]))
        await refused.load()
        #expect(refused.phase.problem?.knownCode == .authUnauthenticated)
    }

    @Test("a failed reload (pull to refresh) keeps the groups on screen")
    func failedReload() async {
        let model = CommunityModel(service: FakeCommunityService(failures: ["directory": [nil, FakeCommunityService.Offline()]]))
        await model.load()
        await model.load()
        #expect(model.groups.count == 1)
    }

    @Test("a failure stands for the connection or the API's problem")
    func failure() {
        #expect(CommunityFailure(FakeCommunityService.Offline()) == .connection)
        #expect(CommunityFailure.connection.screenProblem == AppProblem())
        let problem = communityProblem(.communityGroupNotFound)
        #expect(CommunityFailure(problem) == .problem(problem))
        #expect(CommunityFailure(problem).screenProblem == problem)
    }
}

extension ScreenPhase {
    /** The problem of a failed phase, nil otherwise. */
    var problem: AppProblem? {
        if case .failed(let problem) = self { return problem }
        return nil
    }
}
