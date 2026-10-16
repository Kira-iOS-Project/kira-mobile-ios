import APIClient
import Domain
import Testing

@testable import Features

@MainActor
@Suite("Laporkan Grup through Detail Grup")
struct GroupReportFlowTests {
    private func model(_ service: FakeCommunityService) async -> GroupDetailModel {
        let model = GroupDetailModel(groupID: "g-1", service: service)
        await model.load()
        model.report()
        return model
    }

    @Test("nothing is sent without a reason; a sent report closes the sheet and shows Laporan Terkirim")
    func sent() async {
        let service = FakeCommunityService()
        let model = await model(service)
        #expect(model.showsReport)
        await model.sendReport()
        let calls = await service.calls
        #expect(model.showsReport && calls == [.group("g-1")])
        model.reportForm.choose(.other)
        model.reportForm.report.story = "  Admin jualan data.  "
        await model.sendReport()
        #expect(!model.showsReport && model.showsReportSent)
        #expect(await service.calls.last == .report("g-1", .other, "Admin jualan data."))
        #expect(model.reportForm.report == GroupReport())
    }

    @Test("offline closes the sheet and keeps the report; Coba Lagi reopens it and sends again")
    func offlineRetry() async {
        let service = FakeCommunityService(failures: ["report": [FakeCommunityService.Offline()]])
        let model = await model(service)
        model.reportForm.choose(.scam)
        await model.sendReport()
        #expect(!model.showsReport && model.failure?.failure == .connection && model.failure?.attempt == .report)
        #expect(model.reportForm.report.reason == .scam && model.canRetry)
        await model.retry()
        #expect(model.showsReportSent && !model.showsReport)
    }

    @Test("a duplicate after a lost answer is the report already sent")
    func duplicateAfterLostAnswer() async {
        let model = await model(
            FakeCommunityService(failures: [
                "report": [FakeCommunityService.Offline(), communityProblem(.communityReportDuplicate)]
            ]))
        model.reportForm.choose(.scam)
        await model.sendReport()
        await model.retry()
        #expect(model.showsReportSent)
    }

    @Test("an open report already, a gone group or a refused story show their problem; duplicates offer no retry")
    func refusals() async {
        for code in [ProblemCode.communityReportDuplicate, .communityGroupNotFound, .validationFailed] {
            let model = await model(FakeCommunityService(failures: ["report": [communityProblem(code)]]))
            model.reportForm.choose(.inappropriate)
            await model.sendReport()
            #expect(model.failure?.failure == .problem(communityProblem(code)))
            #expect(model.canRetry == (code != .communityReportDuplicate))
            #expect(model.reportForm.report.reason == .inappropriate)
        }
    }

    @Test("a second send while one is on its way does nothing")
    func busy() async {
        let form = GroupReportModel(groupID: "g-1", service: FakeCommunityService())
        form.choose(.scam)
        async let first = form.send()
        async let second = form.send()
        let outcomes = await [first, second]
        #expect(outcomes.contains(.sent))
    }
}
