import Foundation
import Testing

@testable import Domain

@Suite("NegotiationScript")
struct NegotiationScriptTests {
    @Test("masks the contract number to its last four characters, half of a short one, none while empty")
    func masking() {
        var script = NegotiationScript(name: "Dinda", reason: "penghasilan berkurang")
        #expect(script.maskedContract == nil)
        script.contractNumber = "PB-0098 4821"
        #expect(script.contractCharacters == "PB00984821")
        #expect(script.maskedContract == "••••4821")
        script.contractNumber = "4821"
        #expect(script.maskedContract == "••••21")
        script.contractNumber = "7"
        #expect(script.maskedContract == "••••")
    }

    @Test("fills the template masked for the screen and whole for the clipboard, gaps left nil")
    func fill() {
        var script = NegotiationScript(
            name: "Dinda", contractNumber: "PB-0098 4821", currentInstalment: 230_000, affordable: 150_000,
            reason: " penghasilan berkurang ")
        let screen = script.fill(for: .screen)
        #expect(screen.name == "Dinda" && screen.contract == "••••4821")
        #expect(screen.instalment == 230_000 && screen.affordable == 150_000)
        #expect(screen.reason == "penghasilan berkurang")
        #expect(script.fill(for: .clipboard).contract == "PB-0098 4821")
        script.name = ""
        script.contractNumber = " - "
        script.currentInstalment = nil
        script.affordable = nil
        script.reason = ""
        let gaps = script.fill(for: .clipboard)
        #expect(gaps.name == nil && gaps.contract == nil && gaps.instalment == 0 && gaps.affordable == 0)
        #expect(gaps.reason.isEmpty)
        #expect(script.fill(for: .screen).contract == nil)
    }

    @Test("may be copied with both amounts and a reason; the contract number may stay a gap")
    func completeness() {
        var script = NegotiationScript(name: "Dinda", currentInstalment: 230_000, affordable: 150_000, reason: "  ")
        #expect(script.trimmedReason == nil && !script.isComplete)
        script.reason = " penghasilan berkurang "
        #expect(script.trimmedReason == "penghasilan berkurang" && script.isComplete)
        script.affordable = nil
        #expect(!script.isComplete)
        script.affordable = 150_000
        script.currentInstalment = nil
        #expect(!script.isComplete)
    }
}

@Suite("SafetyPlan")
struct SafetyPlanTests {
    @Test("starts empty, as a plan nobody has written")
    func empty() {
        #expect(SafetyPlan.empty == SafetyPlan())
        #expect(SafetyPlan.empty.people.isEmpty && SafetyPlan.empty.updatedAt == nil)
    }

    @Test("trims and cuts every text to 500 characters, drops blank contacts, keeps three per part")
    func cleaned() {
        let long = String(repeating: "a", count: 600)
        let four = (1...4).map { SafetyContact(name: "Kontak \($0)", phone: "0812") }
        let plan = SafetyPlan(
            warningSigns: "  susah tidur  ", calmingThings: long,
            people: [SafetyContact(name: " ", phone: " ")] + four,
            professionals: [SafetyContact(name: "", phone: "119")], safePlace: "rumah\n",
            updatedAt: Date(timeIntervalSince1970: 1)
        ).cleaned
        #expect(plan.warningSigns == "susah tidur" && plan.safePlace == "rumah")
        #expect(plan.calmingThings.count == SafetyPlan.maximumTextLength)
        #expect(plan.people.map(\.name) == ["Kontak 1", "Kontak 2", "Kontak 3"])
        #expect(plan.professionals == [SafetyContact(name: "", phone: "119")])
        #expect(plan.updatedAt == Date(timeIntervalSince1970: 1))
    }

    @Test(
        "dials digits with a leading plus, an extension after a pause, nothing without a digit",
        arguments: [
            ("0812-3456-7890", "081234567890"), ("+62 812 3456", "+628123456"), ("119 ekstensi 8", "119,8"),
            ("119 eks 8", "119,8"), ("119 ext. 8", "119,8"), ("119 ext", "119"), ("021 (555) 1234", "0215551234"),
        ])
    func dialable(phone: String, dialed: String) {
        #expect(SafetyContact(name: "x", phone: phone).dialable == dialed)
    }

    @Test("has nothing to dial without a digit")
    func notDialable() {
        #expect(SafetyContact(name: "Ibu", phone: "").dialable == nil)
        #expect(SafetyContact(name: "Ibu", phone: "ext 8").dialable == nil)
    }
}

@Suite("BreathingPattern")
struct BreathingPatternTests {
    private let pattern = BreathingPattern.calming

    @Test("is 4-4-6, five rounds of fourteen seconds")
    func lengths() {
        #expect(pattern.roundSeconds == 14 && pattern.totalSeconds == 70)
        #expect(BreathingPattern.Step.allCases.map(pattern.seconds(of:)) == [4, 4, 6])
    }

    @Test(
        "follows the steps second by second",
        arguments: [
            (0, 1, BreathingPattern.Step.inhale, 4), (3, 1, .inhale, 1), (4, 1, .hold, 4), (7, 1, .hold, 1),
            (8, 1, .exhale, 6), (13, 1, .exhale, 1), (14, 2, .inhale, 4), (69, 5, .exhale, 1),
        ])
    func moment(elapsed: Int, round: Int, step: BreathingPattern.Step, left: Int) {
        #expect(pattern.moment(at: elapsed) == BreathingPattern.Moment(round: round, step: step, secondsLeft: left))
    }

    @Test("is over after the last round, and never before it starts")
    func bounds() {
        #expect(pattern.moment(at: 70) == nil)
        #expect(pattern.moment(at: -1) == nil)
    }
}

@Suite("CareDebt")
struct CareDebtTests {
    @Test("keeps the lender and its instalment")
    func fields() {
        let debt = CareDebt(
            id: "d1", name: "Paylater B", kind: .paylater, remaining: 1_200_000, monthlyInstalment: 230_000)
        #expect(debt.id == "d1" && debt.name == "Paylater B" && debt.kind == .paylater)
        #expect(debt.remaining == 1_200_000 && debt.monthlyInstalment == 230_000)
    }
}
