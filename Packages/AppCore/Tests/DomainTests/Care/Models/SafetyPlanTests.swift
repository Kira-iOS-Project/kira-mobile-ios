import Domain
import Foundation
import Testing

@Suite("SafetyPlan: limits, calls and lines")
struct SafetyPlanLimitsTests {
    @Test("a text is too long past 500 characters, counted as it is saved")
    func textLimit() {
        #expect(!SafetyPlan.isTooLong(String(repeating: "a", count: 500)))
        #expect(!SafetyPlan.isTooLong("  " + String(repeating: "a", count: 500) + "\n"))
        #expect(SafetyPlan.isTooLong(String(repeating: "a", count: 501)))
    }

    @Test("a plan is too long when any of its texts is, contacts included")
    func planLimit() {
        let long = String(repeating: "a", count: 501)
        #expect(!SafetyPlan(warningSigns: "susah tidur").isTooLong)
        #expect(SafetyPlan(safePlace: long).isTooLong)
        #expect(SafetyPlan(people: [SafetyContact(name: long, phone: "")]).isTooLong)
        #expect(SafetyPlan(professionals: [SafetyContact(name: "Healing119", phone: long)]).isTooLong)
    }

    @Test("a contact calls its number with the extension after a pause, or nothing without a digit")
    func callURL() {
        #expect(SafetyContact(name: "Healing119", phone: "119 ekstensi 8").callURL?.absoluteString == "tel:119,8")
        #expect(SafetyContact(name: "Ibu", phone: "+62 812-3456").callURL?.absoluteString == "tel:+628123456")
        #expect(SafetyContact(name: "Layanan Kira Peduli · tim Kira", phone: "").callURL == nil)
    }

    @Test("a contact shows as its name and number, leaving out what is not written")
    func line() {
        #expect(SafetyContact(name: "Healing119", phone: "119 ekstensi 8").line == "Healing119 · 119 ekstensi 8")
        #expect(SafetyContact(name: "Ibu", phone: "").line == "Ibu")
        #expect(SafetyContact(name: "", phone: "0812").line == "0812")
    }
}
