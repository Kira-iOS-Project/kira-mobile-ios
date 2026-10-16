import Domain
import Testing

@testable import Features

@MainActor
@Suite("ProtectionAnswersModel")
struct ProtectionAnswersModelTests {
    @Test("starts with no dependents, single and nothing chosen")
    func defaults() {
        let model = ProtectionAnswersModel()
        #expect(model.dependents == 0 && model.maritalStatus == .single)
        #expect(model.protections.isEmpty && !model.hasNone)
        #expect(ProtectionAnswersModel.maximumDependents == 3)
    }

    @Test("protections toggle; Belum Ada clears them and a protection un-chooses it")
    func toggles() {
        let model = ProtectionAnswersModel()
        model.toggle(.bpjsHealth)
        model.toggle(.lifeInsurance)
        model.toggle(.lifeInsurance)
        #expect(model.protections == [.bpjsHealth])
        model.toggleNone()
        #expect(model.hasNone && model.protections.isEmpty)
        model.toggle(.privateHealth)
        #expect(!model.hasNone && model.protections == [.privateHealth])
        model.toggle(.privateHealth)
        model.toggleNone()
        model.toggleNone()
        #expect(!model.hasNone)
    }
}
