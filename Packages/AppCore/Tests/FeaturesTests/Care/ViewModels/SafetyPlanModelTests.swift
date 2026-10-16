import APIClient
import Domain
import Foundation
import Testing

@testable import Features

@MainActor
@Suite("SafetyPlanModel")
struct SafetyPlanModelTests {
    private let service = FakeCareToolsService()

    @Test("loads the saved plan; none saved yet is an empty plan, not a failure")
    func load() async {
        let model = SafetyPlanModel(service: service)
        await model.load()
        #expect(model.phase.value?.warningSigns == "susah tidur")
        await service.configure { $0.plan = nil }
        await model.load()
        #expect(model.phase.value == .empty)
    }

    @Test("a refused or lost load shows the problem", arguments: [true, false])
    func failure(offline: Bool) async {
        await service.configure { $0.failing[.plan] = offline ? FakeCareToolsService.Offline() : FakeCareToolsService.problem }
        let model = SafetyPlanModel(service: service)
        await model.load()
        guard case .failed(let problem) = model.phase else { Issue.record("expected failed"); return }
        #expect(problem == (offline ? AppProblem() : FakeCareToolsService.problem))
    }

    @Test("a pencil opens the form on the plan, focused on its part; a save shows on the plan")
    func edit() async throws {
        let model = SafetyPlanModel(service: service)
        model.edit(.people)
        #expect(model.form?.plan.people == [SafetyContact(name: "", phone: "")])
        await model.load()
        model.edit(.safePlace)
        let form = try #require(model.form)
        #expect(form.focus == .safePlace && form.plan.safePlace == "rumah keluarga")
        form.plan.calmingThings = "jalan sore"
        await form.save()
        #expect(model.phase.value?.calmingThings == "jalan sore")
        #expect(SafetyPlanPart.allCases.map(\.rawValue) == [1, 2, 3, 4, 5])
    }
}

@MainActor
@Suite("SafetyPlanFormModel")
struct SafetyPlanFormModelTests {
    private let service = FakeCareToolsService()

    @MainActor final class Saved { var plans: [SafetyPlan] = [] }

    private func form(_ plan: SafetyPlan = .empty, saved: Saved = Saved()) -> SafetyPlanFormModel {
        SafetyPlanFormModel(plan: plan, focus: .warningSigns, service: service) { saved.plans.append($0) }
    }

    @Test("parts 3 and 4 start with one empty contact and take up to three")
    func contacts() {
        let form = form()
        #expect(form.plan.people.count == 1 && form.plan.professionals.count == 1)
        form.addContact(to: .people)
        form.addContact(to: .people)
        #expect(!form.canAdd(to: .people) && form.canAdd(to: .professionals))
        form.addContact(to: .people)
        #expect(form.plan.people.count == 3)
        form.removeContact(at: 1, from: .people)
        form.removeContact(at: 9, from: .people)
        form.removeContact(at: 0, from: .professionals)
        #expect(form.plan.people.count == 2 && form.plan.professionals.isEmpty)
    }

    @Test("saves the cleaned plan, shows Rencana Tersimpan, and leaves when it closes")
    func save() async {
        let saved = Saved()
        let form = form(saved: saved)
        form.plan.warningSigns = "  susah tidur  "
        form.plan.people = [SafetyContact(name: "Ibu", phone: "0812")]
        await form.save()
        #expect(await service.saved.first?.warningSigns == "susah tidur")
        #expect(saved.plans.first?.updatedAt != nil)
        #expect(form.dialog == .saved && form.shownDialog == .saved && !form.isSaving)
        form.dialogClosed()
        #expect(form.isFinished && form.dialog == nil)
    }

    @Test("a refused or lost save keeps every field and offers Coba Lagi", arguments: [true, false])
    func saveFailure(offline: Bool) async {
        await service.configure { $0.failing[.save] = offline ? FakeCareToolsService.Offline() : FakeCareToolsService.problem }
        let saved = Saved()
        let form = form(saved: saved)
        form.plan.safePlace = "rumah keluarga"
        await form.save()
        #expect(form.dialog == .failed(offline ? AppProblem() : FakeCareToolsService.problem))
        #expect(form.plan.safePlace == "rumah keluarga" && saved.plans.isEmpty)
        form.dialogClosed()
        #expect(!form.isFinished)
        await service.configure { $0.failing = [:] }
        await form.save()
        #expect(form.dialog == .saved && saved.plans.count == 1)
    }

    @Test("a save already running is not started twice")
    func saveOnce() async {
        let form = form()
        async let first: Void = form.save()
        async let second: Void = form.save()
        _ = await (first, second)
        #expect(await service.saved.count == 1)
    }
}
