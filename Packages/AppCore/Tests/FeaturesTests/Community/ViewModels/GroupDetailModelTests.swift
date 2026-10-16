import APIClient
import Domain
import Testing

@testable import Features

@MainActor
@Suite("GroupDetailModel")
struct GroupDetailModelTests {
    private func loaded(_ service: FakeCommunityService) async -> GroupDetailModel {
        let model = GroupDetailModel(groupID: "g-1", service: service)
        await model.load()
        return model
    }

    @Test("loads the group; a gone or suspended group shows its problem; offline the generic one")
    func load() async {
        let model = await loaded(FakeCommunityService())
        #expect(model.phase.value?.summary.name == "Lunas Bareng Jakarta")
        let gone = await loaded(FakeCommunityService(failures: ["group": [communityProblem(.communityGroupNotFound)]]))
        #expect(gone.phase.problem?.knownCode == .communityGroupNotFound)
        let offline = await loaded(FakeCommunityService(failures: ["group": [FakeCommunityService.Offline()]]))
        #expect(offline.phase.problem == AppProblem())
        await model.load()
        #expect(model.phase.value != nil)
        await model.join()
        let reloaded = await loaded(FakeCommunityService(failures: ["group": [nil, FakeCommunityService.Offline()]]))
        await reloaded.load()
        #expect(reloaded.phase.value != nil)
    }

    @Test("joining without the rules opens them; agreeing keeps them, then the invite opens Tautan Keluar")
    func rulesThenInvite() async {
        let service = FakeCommunityService()
        let model = await loaded(service)
        await model.join()
        #expect(model.showsRules && !model.rulesAgreed && model.invite == nil)
        await model.acceptRules()
        #expect(await service.calls.count == 1)
        model.rulesAgreed = true
        await model.acceptRules()
        #expect(!model.showsRules && model.phase.value?.rulesAccepted == true)
        #expect(model.invite == FakeCommunityService.invite)
        #expect(await service.calls == [.group("g-1"), .acceptRules(CommunityRules.version), .join("g-1")])
    }

    @Test("rules already accepted go straight to the invite; nothing happens before the group loads")
    func accepted() async {
        let service = FakeCommunityService(rulesAccepted: true)
        let idle = GroupDetailModel(groupID: "g-1", service: service)
        await idle.join()
        await idle.acceptRules()
        let model = await loaded(service)
        await model.join()
        #expect(!model.showsRules && model.invite != nil)
    }

    @Test("a new rules version on join asks for the rules again; a group gone on join shows its problem")
    func joinRefusals() async {
        let rules = await loaded(
            FakeCommunityService(
                rulesAccepted: true, failures: ["join": [communityProblem(.communityRulesNotAccepted)]]))
        await rules.join()
        #expect(rules.showsRules && rules.invite == nil && rules.failure == nil)
        let gone = await loaded(
            FakeCommunityService(rulesAccepted: true, failures: ["join": [communityProblem(.communityGroupNotFound)]]))
        await gone.join()
        #expect(gone.phase.problem?.knownCode == .communityGroupNotFound)
    }

    @Test("a link still being checked shows its message without Coba Lagi")
    func linkUnavailable() async {
        let model = await loaded(
            FakeCommunityService(rulesAccepted: true, failures: ["join": [communityProblem(.communityLinkUnavailable)]])
        )
        await model.join()
        #expect(model.failure?.failure == .problem(communityProblem(.communityLinkUnavailable)))
        #expect(model.failure?.attempt == .join && !model.canRetry)
        model.dismissFailure()
        #expect(model.failure == nil)
    }

    @Test("a dropped join shows the dialog; Coba Lagi asks again and opens the link")
    func joinRetry() async {
        let model = await loaded(
            FakeCommunityService(rulesAccepted: true, failures: ["join": [FakeCommunityService.Offline()]]))
        await model.join()
        #expect(model.failure?.failure == .connection && model.canRetry)
        await model.retry()
        #expect(model.failure == nil && model.invite != nil)
        await model.retry()
    }

    @Test("a failed consent closes the sheet with the tick kept; Coba Lagi reopens it and sends again")
    func rulesRetry() async {
        let service = FakeCommunityService(failures: ["acceptRules": [FakeCommunityService.Offline()]])
        let model = await loaded(service)
        await model.join()
        model.rulesAgreed = true
        await model.acceptRules()
        #expect(!model.showsRules && model.rulesAgreed && model.failure?.attempt == .acceptRules)
        await model.retry()
        #expect(model.invite != nil && model.phase.value?.rulesAccepted == true)
    }

    @Test("an old rules version refused (422) shows without Coba Lagi, drops the tick on Tutup, and reloads")
    func rulesRefused() async {
        let service = FakeCommunityService(failures: ["acceptRules": [communityProblem(.validationFailed)]])
        let model = await loaded(service)
        await model.join()
        model.rulesAgreed = true
        await model.acceptRules()
        #expect(model.failure?.attempt == .acceptRules && !model.canRetry)
        #expect(await service.calls.filter { $0 == .group("g-1") }.count == 2)
        model.dismissFailure()
        #expect(!model.rulesAgreed && model.failure == nil)
    }

    @Test("a load or a join cancelled with its task changes nothing")
    func cancelled() async {
        let model = await loaded(
            FakeCommunityService(rulesAccepted: true, failures: ["join": [CancellationError()]]))
        await model.join()
        #expect(model.failure == nil && model.invite == nil && model.phase.value != nil)
        let loading = GroupDetailModel(
            groupID: "g-1", service: FakeCommunityService(failures: ["group": [CancellationError()]]))
        await loading.load()
        #expect(loading.phase.value == nil && loading.phase.problem == nil)
    }

}
