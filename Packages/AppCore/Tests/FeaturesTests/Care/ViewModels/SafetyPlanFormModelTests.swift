import APIClient
import Domain
import Foundation
import Testing

@testable import Features

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
