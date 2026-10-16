import APIClient
import Domain
import Testing

@testable import Features

@MainActor
@Suite("GroupReportModel")
struct GroupReportModelTests {
    private let service = ReportOnlyService()

    private func model(reason: GroupReportReason? = nil, story: String = "") -> GroupReportModel {
        let model = GroupReportModel(groupID: "g-lunas", service: service)
        if let reason { model.choose(reason) }
        model.report.story = story
        return model
    }

    @Test("nothing is sent without a reason")
    func noReason() async {
        #expect(await model().send() == nil)
        #expect(await service.calls.isEmpty)
    }

    @Test("Lainnya needs a story that is not blank (KOM-05d); the check stays inline")
    func otherNeedsStory() async {
        let model = model(reason: .other, story: "   \n ")
        #expect(model.report.requiresStory && !model.report.canSend)
        #expect(await model.send() == nil)
        #expect(await service.calls.isEmpty)
    }

    @Test("a story over 500 characters is not sent; exactly 500 is")
    func storyLimit() async {
        #expect(await model(reason: .scam, story: String(repeating: "a", count: 501)).send() == nil)
        #expect(await service.calls.isEmpty)
        #expect(await model(reason: .scam, story: String(repeating: "a", count: 500)).send() == .sent)
    }

    @Test("sent: the story is trimmed, a blank one is nil, and the form starts over")
    func sent() async {
        let model = model(reason: .other, story: "  Admin minta transfer dulu.  ")
        #expect(await model.send() == .sent)
        #expect(await service.calls == [.init(groupID: "g-lunas", reason: .other, story: "Admin minta transfer dulu.")])
        #expect(model.report == GroupReport())
        #expect(await self.model(reason: .scam, story: "  ").send() == .sent)
        #expect(await service.calls.last?.story == nil)
    }

    @Test(
        "a refusal fails with its problem and keeps the reason and story (KOM-05c)",
        arguments: ["COMMUNITY_REPORT_DUPLICATE", "COMMUNITY_GROUP_NOT_FOUND", "VALIDATION_FAILED"])
    func refused(code: String) async {
        await service.answer(with: AppProblem(code: code))
        let model = model(reason: .other, story: "Ada yang jual data.")
        #expect(await model.send() == .failed(.problem(AppProblem(code: code))))
        #expect(model.report == GroupReport(reason: .other, story: "Ada yang jual data."))
        #expect(!model.isSending)
    }

    @Test("offline fails as a connection failure; Coba Lagi sends the same report again")
    func offlineThenRetry() async {
        await service.answer(with: OfflineError())
        let model = model(reason: .guaranteedProfit, story: "Janji 20% sebulan.")
        #expect(await model.send() == .failed(.connection))
        #expect(model.report == GroupReport(reason: .guaranteedProfit, story: "Janji 20% sebulan."))
        await service.answer(with: nil)
        #expect(await model.send() == .sent)
        let calls = await service.calls
        #expect(calls.count == 2 && calls[0] == calls[1])
    }

    @Test("a duplicate right after a lost answer means the first send landed: sent")
    func duplicateAfterLostAnswer() async {
        await service.answer(with: OfflineError())
        let model = model(reason: .scam)
        #expect(await model.send() == .failed(.connection))
        await service.answer(with: AppProblem(code: "COMMUNITY_REPORT_DUPLICATE"))
        #expect(await model.send() == .sent)
    }

    @Test("a duplicate with no lost answer before it is a real refusal")
    func duplicateIsRefused() async {
        await service.answer(with: AppProblem(code: "COMMUNITY_REPORT_DUPLICATE"))
        let duplicate = AppProblem(code: "COMMUNITY_REPORT_DUPLICATE")
        let model = model(reason: .scam)
        #expect(await model.send() == .failed(.problem(duplicate)))
        await service.answer(with: OfflineError())
        #expect(await model.send() == .failed(.connection))
        await service.answer(with: AppProblem(code: "VALIDATION_FAILED"))
        #expect(await model.send() == .failed(.problem(AppProblem(code: "VALIDATION_FAILED"))))
        await service.answer(with: duplicate)
        #expect(await model.send() == .failed(.problem(duplicate)))
    }
}

/** A Komunitas service that only takes reports: it records each and answers with `error` when set. */
private actor ReportOnlyService: CommunityService {
    struct Call: Equatable {
        let groupID: String
        let reason: GroupReportReason
        let story: String?
    }

    private(set) var calls: [Call] = []
    private var error: (any Error)?

    /** Answers the next sends with `error`, or with success when nil. */
    func answer(with error: (any Error)?) {
        self.error = error
    }

    func report(groupID: String, reason: GroupReportReason, story: String?) throws {
        calls.append(Call(groupID: groupID, reason: reason, story: story))
        if let error { throw error }
    }

    func directory() throws -> CommunityDirectory { throw OfflineError() }
    func group(id _: String) throws -> CommunityGroup { throw OfflineError() }
    func acceptRules(version _: String) throws { throw OfflineError() }
    func join(groupID _: String) throws -> GroupInvite { throw OfflineError() }
}
