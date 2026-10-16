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
        let error: any Error = offline ? FakeCareToolsService.Offline() : FakeCareToolsService.problem
        await service.configure { $0.failing[.plan] = error }
        let model = SafetyPlanModel(service: service)
        await model.load()
        guard case .failed(let problem) = model.phase else { Issue.record("expected failed"); return }
        #expect(problem == (offline ? AppProblem() : FakeCareToolsService.problem))
    }

    @Test("a lost connection reads as one, on the load and on the save, never as an unknown problem")
    func connectionLost() async {
        await service.configure { $0.failing[.plan] = URLError(.timedOut) }
        let model = SafetyPlanModel(service: service)
        await model.load()
        guard case .failed(let problem) = model.phase else { Issue.record("expected failed"); return }
        #expect(problem.isConnectionLoss)
        await service.configure { $0.failing = [.save: URLError(.networkConnectionLost)] }
        await model.load()
        await model.saveShown()
        #expect(model.dialog == .failed(.connectionLost))
    }

    @Test("a pencil opens the form on the plan, focused on its part; its save closes it with Rencana Tersimpan")
    func editAndSave() async throws {
        let model = SafetyPlanModel(service: service)
        model.edit(.people)
        #expect(model.form?.plan.people == [SafetyContact(name: "", phone: "")])
        await model.load()
        model.edit(.safePlace)
        let form = try #require(model.form)
        #expect(form.focus == .safePlace && form.plan.safePlace == "rumah keluarga")
        form.plan.calmingThings = "  jalan sore  "
        await form.save()
        #expect(await service.saved.last?.calmingThings == "jalan sore")
        #expect(model.phase.value?.calmingThings == "jalan sore" && model.phase.value?.updatedAt != nil)
        #expect(model.form == nil && model.dialog == .saved && model.shownDialog == .saved && !model.isSaving)
        model.dialogClosed()
        #expect(model.isFinished && model.dialog == nil)
        #expect(SafetyPlanPart.allCases.map(\.rawValue) == [1, 2, 3, 4, 5])
    }

    @Test("Simpan Rencana under the plan saves it as it shows, and only once it has loaded")
    func saveShown() async {
        let model = SafetyPlanModel(service: service)
        await model.saveShown()
        #expect(await service.saved.isEmpty)
        await model.load()
        await model.saveShown()
        #expect(await service.saved.first?.safePlace == "rumah keluarga" && model.dialog == .saved)
    }

    @Test(
        "a refused, invalid or lost save closes the form, shows its problem, and Coba Lagi reopens it as written",
        arguments: [FakeCareToolsService.Offline() as any Error, FakeCareToolsService.problem,
            AppProblem(code: "AUTH_UNAUTHENTICATED"), URLError(.notConnectedToInternet)])
    func saveFailure(error: any Error) async throws {
        await service.configure { $0.failing[.save] = error }
        let model = SafetyPlanModel(service: service)
        await model.load()
        model.edit(.calmingThings)
        try #require(model.form).plan.calmingThings = "dengar lagu"
        await model.form?.save()
        #expect(model.form == nil && model.dialog == .failed(AppProblem(error)))
        #expect(model.phase.value?.calmingThings == "")
        model.retry()
        let reopened = try #require(model.form)
        #expect(model.dialog == nil && reopened.focus == .calmingThings && reopened.plan.calmingThings == "dengar lagu")
        await service.configure { $0.failing = [:] }
        await reopened.save()
        #expect(model.dialog == .saved && model.phase.value?.calmingThings == "dengar lagu")
    }

    @Test("Tutup keeps what was written for the next pencil; Coba Lagi with nothing kept only closes")
    func closeKeeps() async throws {
        await service.configure { $0.failing[.save] = FakeCareToolsService.problem }
        let model = SafetyPlanModel(service: service)
        model.retry()
        #expect(model.form == nil)
        await model.load()
        model.edit(.warningSigns)
        try #require(model.form).plan.warningSigns = "malas makan"
        await model.form?.save()
        model.dialogClosed()
        #expect(!model.isFinished && model.dialog == nil)
        model.edit(.safePlace)
        #expect(model.form?.plan.warningSigns == "malas makan" && model.form?.focus == .safePlace)
    }

    @Test("a save already running is not started twice")
    func saveOnce() async {
        let model = SafetyPlanModel(service: service)
        await model.load()
        async let first: Void = model.saveShown()
        async let second: Void = model.saveShown()
        _ = await (first, second)
        #expect(await service.saved.count == 1)
    }
}

@MainActor
@Suite("SafetyPlanFormModel")
struct SafetyPlanFormModelTests {
    @MainActor final class Saved { var plans: [(SafetyPlan, SafetyPlanPart)] = [] }

    private func form(_ plan: SafetyPlan = .empty, saved: Saved = Saved()) -> SafetyPlanFormModel {
        SafetyPlanFormModel(plan: plan, focus: .people) { saved.plans.append(($0, $1)) }
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

    @Test("Simpan Rencana hands over the plan and its part, and holds back while a text is over 500")
    func save() async {
        let saved = Saved()
        let form = form(SafetyPlan(people: [SafetyContact(name: "Ibu", phone: "0812")]), saved: saved)
        form.plan.safePlace = String(repeating: "a", count: 501)
        #expect(!form.canSave)
        await form.save()
        #expect(saved.plans.isEmpty)
        form.plan.safePlace = "rumah"
        #expect(form.canSave)
        await form.save()
        #expect(saved.plans.first?.0.safePlace == "rumah" && saved.plans.first?.1 == .people && !form.isSaving)
    }
}
