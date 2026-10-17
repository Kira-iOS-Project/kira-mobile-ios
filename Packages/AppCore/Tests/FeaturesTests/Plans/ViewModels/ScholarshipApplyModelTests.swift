import APIClient
import Domain
import Testing

@testable import Features

@MainActor
@Suite("ScholarshipApplyModel")
struct ScholarshipApplyModelTests {
    @Test("loads the account email, or the problem")
    func loads() async {
        let model = ScholarshipApplyModel(service: FakePlansService())
        await model.load()
        #expect(model.phase.value == "dinda@email.com")
        let broken = ScholarshipApplyModel(service: FakePlansService(emailResult: .failure(problem("X"))))
        await broken.load()
        guard case .failed = broken.phase else {
            Issue.record("expected a failure")
            return
        }
    }

    @Test("a failed email load blocks sending, and Coba Lagi loads it again with the form kept")
    func retriesTheEmail() async {
        let service = FakePlansService(emailFailures: 1)
        let model = ScholarshipApplyModel(service: service)
        model.toggle(.medicalCosts)
        model.story = "Cicilan menumpuk."
        await model.load()
        #expect(!model.canSend)
        await model.send()
        #expect(model.sent == nil)
        await model.load()
        #expect(model.phase.value == "dinda@email.com")
        #expect(model.situations == [.medicalCosts] && model.story == "Cicilan menumpuk.")
        #expect(model.canSend)
    }

    @Test("needs a situation and a story within its limit")
    func canSend() async {
        let service = FakePlansService()
        let model = ScholarshipApplyModel(service: service)
        model.toggle(.medicalCosts)
        #expect(!model.canSend)
        await model.load()
        model.toggle(.medicalCosts)
        #expect(!model.canSend)
        await model.send()
        #expect(await service.log.calls == ["email"])
        model.toggle(.medicalCosts)
        #expect(model.canSend)
        model.story = String(repeating: "a", count: ScholarshipApplyModel.storyLimit + 1)
        #expect(model.isStoryTooLong)
        #expect(!model.canSend)
        model.toggle(.medicalCosts)
        #expect(model.situations.isEmpty)
    }

    @Test("sends the situations in the form's order, a blank story left out")
    func sends() async {
        let service = FakePlansService()
        let model = ScholarshipApplyModel(service: service)
        await model.load()
        model.toggle(.chasedByLender)
        model.toggle(.instalmentsPilingUp)
        model.story = "  \n"
        await model.send()
        #expect(model.sent == PlansFixtures.application())
        #expect(!model.isSending)
        model.story = " Aku mau mencatat semua cicilan. "
        await model.send()
        #expect(
            await service.log.calls == [
                "email",
                "apply instalments_piling_up,chased_by_lender -",
                "apply instalments_piling_up,chased_by_lender Aku mau mencatat semua cicilan.",
            ])
    }

    @Test("keeps the problem of a refused application")
    func refused() async {
        let model = ScholarshipApplyModel(
            service: FakePlansService(applyResult: .failure(problem("SCHOLARSHIP_NOT_ELIGIBLE"))))
        await model.load()
        model.toggle(.otherHardship)
        await model.send()
        #expect(model.sent == nil)
        #expect(model.sendProblem?.code == "SCHOLARSHIP_NOT_ELIGIBLE")
    }
}
