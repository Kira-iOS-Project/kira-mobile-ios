/**
 Kira Peduli's tools on the canvas's sample: Dinda with the four lenders of NaskahNegosiasiDropdown
 (Paylater B picked on the board) and the safety plan of RencanaKeselamatan. Nothing leaves the
 device; a saved plan is kept in memory.
 */
import Domain
import Features
import Foundation

actor PreviewCareToolsService: CareToolsService {
    private var plan: SafetyPlan?

    /** The sample, with the board's plan unless `plan` says otherwise (nil: none saved yet). */
    init(plan: SafetyPlan? = PreviewCareToolsService.samplePlan) {
        self.plan = plan
    }

    func displayName() -> String { "Dinda" }

    func debts() -> [CareDebt] {
        [
            CareDebt(id: "debt-a", name: "Pinjol A", monthlyInstalment: 410_000),
            CareDebt(id: "debt-b", name: "Paylater B", monthlyInstalment: 230_000),
            CareDebt(id: "debt-c", name: "Kartu Kredit C", monthlyInstalment: 520_000),
            CareDebt(id: "debt-d", name: "Pinjol D", monthlyInstalment: 190_000),
        ]
    }

    func safetyPlan() -> SafetyPlan? { plan }

    func saveSafetyPlan(_ plan: SafetyPlan) -> SafetyPlan {
        var stored = plan
        stored.updatedAt = Date(timeIntervalSince1970: 1_792_202_400)
        self.plan = stored
        return stored
    }

    /** RencanaKeselamatan's five parts. */
    static let samplePlan = SafetyPlan(
        warningSigns: "susah tidur, nggak mau buka chat", calmingThings: "jalan sore, mandi air hangat, dengar lagu",
        people: [SafetyContact(name: "Layanan Kira Peduli · tim Kira", phone: "")],
        professionals: [SafetyContact(name: "Healing119", phone: "119 ekstensi 8")], safePlace: "rumah keluarga")
}
