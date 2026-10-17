import Domain
import Foundation
import Testing

@testable import Features

@MainActor
@Suite("Aturan Komunitas's Coba Lagi through Detail Grup")
struct GroupRulesRetryTests {
    private func loaded(_ service: FakeCommunityService) async -> GroupDetailModel {
        let model = GroupDetailModel(groupID: "g-1", service: service)
        await model.load()
        return model
    }

    @Test("a failed consent closes the sheet with the tick kept; Coba Lagi reopens it and sends once it has risen")
    func rulesRetry() async {
        let service = FakeCommunityService(failures: ["acceptRules": [URLError(.notConnectedToInternet)]])
        let model = await loaded(service)
        await model.join()
        model.rulesAgreed = true
        await model.acceptRules()
        #expect(!model.showsRules && model.rulesAgreed && model.failure?.attempt == .acceptRules)
        await model.retry()
        #expect(model.showsRules && model.failure == nil && model.invite == nil)
        #expect(await service.calls.filter { $0 == .acceptRules(CommunityRules.version) }.count == 1)
        await model.sheetShown(.report)
        #expect(model.invite == nil)
        await model.sheetShown(.acceptRules)
        #expect(model.invite != nil && model.phase.value?.rulesAccepted == true)
        await model.sheetShown(.acceptRules)
        #expect(await service.calls.filter { $0 == .acceptRules(CommunityRules.version) }.count == 2)
    }

    @Test("rules opened again by hand drop a retry still waiting: their sheet rising sends nothing")
    func staleRulesRetry() async {
        let service = FakeCommunityService(failures: ["acceptRules": [URLError(.notConnectedToInternet)]])
        let model = await loaded(service)
        await model.join()
        model.rulesAgreed = true
        await model.acceptRules()
        await model.retry()
        model.showsRules = false
        await model.join()
        await model.sheetShown(.acceptRules)
        #expect(model.showsRules && !model.rulesAgreed && model.invite == nil)
        #expect(await service.calls.filter { $0 == .acceptRules(CommunityRules.version) }.count == 1)
    }
}
