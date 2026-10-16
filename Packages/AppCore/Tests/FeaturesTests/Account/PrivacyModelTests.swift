import APIClient
import Domain
import Testing

@testable import Features

@MainActor
@Suite("PrivacyModel")
struct PrivacyModelTests {
    @Test("loads the consents and the account's email")
    func load() async {
        let model = PrivacyModel(service: FakeAccountService())
        await model.load()
        #expect(model.phase.value == PrivacyOverview(consents: Sample.consents(), email: "dinda@email.com"))
    }

    @Test("a failed load shows the problem")
    func loadFails() async {
        let model = PrivacyModel(service: FakeAccountService(consents: nil))
        await model.load()
        guard case .failed(let problem) = model.phase else {
            Issue.record("expected failed")
            return
        }
        #expect(problem == Sample.problem)
    }

    @Test("each switch saves both consents, keeping the other one")
    func switches() async {
        let service = FakeAccountService()
        let model = PrivacyModel(service: service)
        await model.setAIProcessing(false)
        #expect(await service.calls.isEmpty)
        await model.load()
        await model.setAIProcessing(false)
        #expect(model.phase.value?.consents.isGranted(.aiProcessing) == false)
        await model.setWeeklySummary(false)
        #expect(model.phase.value?.consents == Sample.consents(aiProcessing: false, weekly: false))
        #expect(!model.isSaving)
        #expect(
            await service.calls.suffix(2) == ["updateConsents false true", "updateConsents false false"])
    }

    @Test("a refused consent keeps the old one and shows the problem")
    func switchFails() async {
        let service = FakeAccountService()
        let model = PrivacyModel(service: service)
        await model.load()
        await service.set(fails: true)
        await model.setWeeklySummary(false)
        #expect(model.phase.value?.consents == Sample.consents())
        #expect(model.problem == Sample.problem)
    }

    @Test("Unduh hands the CSV to the exporter until it closes")
    func export() async {
        let model = PrivacyModel(service: FakeAccountService())
        await model.exportData()
        #expect(model.export == Sample.export)
        #expect(!model.isExporting)
        model.finishExport()
        #expect(model.export == nil)
    }

    @Test("a failed export shows the problem")
    func exportFails() async {
        let service = FakeAccountService()
        await service.set(fails: true)
        let model = PrivacyModel(service: service)
        await model.exportData()
        #expect(model.export == nil)
        #expect(model.problem == Sample.problem)
    }

    @Test("an error that is not the API's reads as the generic problem")
    func genericProblem() {
        struct Offline: Error {}
        #expect(accountProblem(Offline()) == AppProblem())
        #expect(accountProblem(Sample.problem) == Sample.problem)
    }
}
