import APIClient
import Domain
import Foundation
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

    /** How many reports reached `service`. */
    private func reports(_ service: FakeCommunityService) async -> Int {
        await service.calls.filter {
            if case .report = $0 { true } else { false }
        }.count
    }

    @Test("nothing is sent without a reason; a sent report shows Laporan Terkirim over the sheet")
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
        #expect(model.showsReport && model.showsReportSent && !model.reportFinished)
        #expect(await service.calls.last == .report("g-1", .other, "Admin jualan data."))
        #expect(model.reportForm.report == GroupReport())
        model.finishReport()
        #expect(!model.showsReportSent && model.reportFinished)
    }

    @Test("offline closes the sheet and keeps the report; Coba Lagi reopens it and sends once it has risen")
    func offlineRetry() async {
        let service = FakeCommunityService(failures: ["report": [URLError(.notConnectedToInternet)]])
        let model = await model(service)
        model.reportForm.choose(.scam)
        await model.sendReport()
        #expect(!model.showsReport && model.failure?.failure == .connection && model.failure?.attempt == .report)
        #expect(model.reportForm.report.reason == .scam && model.canRetry)
        await model.retry()
        #expect(model.showsReport && !model.showsReportSent && model.failure == nil)
        #expect(await reports(service) == 1)
        await model.sheetShown(.report)
        #expect(model.showsReportSent && model.showsReport)
    }

    @Test("two failures then a success: each Coba Lagi sends only once its sheet has risen")
    func retryTwice() async {
        let offline = URLError(.notConnectedToInternet)
        let service = FakeCommunityService(failures: ["report": [offline, offline]])
        let model = await model(service)
        model.reportForm.choose(.scam)
        await model.sendReport()
        await model.retry()
        await model.sheetShown(.report)
        #expect(!model.showsReport && model.failure?.attempt == .report && model.reportForm.report.reason == .scam)
        await model.retry()
        await model.sheetShown(.report)
        #expect(model.showsReportSent && model.failure == nil)
        #expect(await reports(service) == 3)
    }

    @Test("Tutup on the failure keeps the reason and story; Laporkan Grup reopens them, and only a send clears them")
    func closeKeeps() async {
        let model = await model(FakeCommunityService(failures: ["report": [URLError(.notConnectedToInternet)]]))
        model.reportForm.choose(.other)
        model.reportForm.report.story = "Admin jualan data."
        await model.sendReport()
        model.dismissFailure()
        #expect(model.failure == nil && model.reportForm.report.reason == .other)
        #expect(model.reportForm.report.story == "Admin jualan data.")
        model.report()
        await model.sheetShown(.report)
        #expect(model.showsReport && !model.showsReportSent)
        await model.sendReport()
        #expect(model.showsReportSent && model.reportForm.report == GroupReport())
    }

    @Test("a duplicate after a lost answer is the report already sent")
    func duplicateAfterLostAnswer() async {
        let model = await model(
            FakeCommunityService(failures: [
                "report": [URLError(.notConnectedToInternet), communityProblem(.communityReportDuplicate)]
            ]))
        model.reportForm.choose(.scam)
        await model.sendReport()
        await model.retry()
        await model.sheetShown(.report)
        #expect(model.showsReportSent)
    }

    @Test("an open report already or a refused story show their problem without Coba Lagi; other problems offer it")
    func refusals() async {
        for code in [ProblemCode.communityReportDuplicate, .validationFailed, .internalError] {
            let model = await model(FakeCommunityService(failures: ["report": [communityProblem(code)]]))
            model.reportForm.choose(.inappropriate)
            await model.sendReport()
            #expect(!model.showsReport && model.failure?.failure == .problem(communityProblem(code)))
            #expect(model.canRetry == (code == .internalError))
            #expect(model.reportForm.report.reason == .inappropriate)
        }
    }

    @Test("a group gone while reporting shows its problem in place of the group, as on joining")
    func goneGroup() async {
        let model = await model(
            FakeCommunityService(failures: ["report": [communityProblem(.communityGroupNotFound)]]))
        model.reportForm.choose(.scam)
        await model.sendReport()
        #expect(!model.showsReport && model.failure == nil)
        #expect(model.phase.problem?.knownCode == .communityGroupNotFound)
    }

    @Test("a send cancelled with its task shows nothing")
    func cancelled() async {
        let model = await model(FakeCommunityService(failures: ["report": [CancellationError()]]))
        model.reportForm.choose(.scam)
        await model.sendReport()
        #expect(model.showsReport && model.failure == nil && !model.showsReportSent)
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
