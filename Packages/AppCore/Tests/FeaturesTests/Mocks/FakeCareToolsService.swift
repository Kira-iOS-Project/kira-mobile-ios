import APIClient
import Domain
import Foundation

@testable import Features

/** The API boundary of Kira Peduli's tools, answering from what a test sets. */
actor FakeCareToolsService: CareToolsService {
    enum Call: Hashable, Sendable {
        case name, debts, plan, save
    }

    static let problem = AppProblem(code: "VALIDATION_FAILED", requestId: "req-1")
    /** A lost connection: not a problem the API answered. */
    struct Offline: Error {}

    var name = "dinda"
    var debtList = [
        CareDebt(id: "a", name: "Pinjol A", monthlyInstalment: 410_000),
        CareDebt(id: "b", name: "Paylater B", monthlyInstalment: 230_000),
    ]
    var plan: SafetyPlan? = SafetyPlan(warningSigns: "susah tidur", safePlace: "rumah keluarga")
    /** The calls that fail, and how. */
    var failing: [Call: any Error] = [:]
    private(set) var saved: [SafetyPlan] = []

    func configure(_ change: @Sendable (isolated FakeCareToolsService) -> Void) { change(self) }

    func displayName() throws -> String {
        try check(.name)
        return name
    }

    func debts() throws -> [CareDebt] {
        try check(.debts)
        return debtList
    }

    func safetyPlan() throws -> SafetyPlan? {
        try check(.plan)
        return plan
    }

    func saveSafetyPlan(_ plan: SafetyPlan) throws -> SafetyPlan {
        saved.append(plan)
        try check(.save)
        var stored = plan
        stored.updatedAt = Date(timeIntervalSince1970: 1_792_130_000)
        return stored
    }

    private func check(_ call: Call) throws {
        if let error = failing[call] { throw error }
    }
}
