import APIClient
import Domain

/** Naskah Pengajuan Keringanan's and Rencana Keselamatanku's calls over the API client. */
package struct LiveCareToolsService: CareToolsService {
    private let api: KiraAPI

    /** Calls through `api`. */
    package init(api: KiraAPI) {
        self.api = api
    }

    /** `GET /me`: the name. */
    package func displayName() async throws -> String {
        try await api.getMe().displayName
    }

    /** `GET /debts`. */
    package func debts() async throws -> [CareDebt] {
        try await api.listDebts().map {
            CareDebt(id: $0.id, name: $0.name, monthlyInstalment: $0.monthlyInstalment)
        }
    }

    /** `GET /care/safety-plan`; nil when none was saved (404 `CARE_SAFETY_PLAN_NOT_FOUND`). */
    package func safetyPlan() async throws -> SafetyPlan? {
        do {
            return SafetyPlan(try await api.getSafetyPlan())
        } catch let problem as AppProblem where problem.knownCode == .careSafetyPlanNotFound {
            return nil
        }
    }

    /** `PUT /care/safety-plan`. */
    package func saveSafetyPlan(_ plan: SafetyPlan) async throws -> SafetyPlan {
        SafetyPlan(try await api.saveSafetyPlan(SafetyPlanDTO(plan)))
    }
}

extension SafetyPlan {
    /** The plan as the API stored it. */
    init(_ plan: SafetyPlanDTO) {
        self.init(
            warningSigns: plan.warningSigns, calmingThings: plan.calmingThings,
            people: plan.people.map { SafetyContact(name: $0.name, phone: $0.phone) },
            professionals: plan.professionals.map { SafetyContact(name: $0.name, phone: $0.phone) },
            safePlace: plan.safePlace, updatedAt: plan.updatedAt)
    }
}

extension SafetyPlanDTO {
    /** The plan to send. */
    init(_ plan: SafetyPlan) {
        self.init(
            warningSigns: plan.warningSigns, calmingThings: plan.calmingThings,
            people: plan.people.map { SafetyPlanPersonDTO(name: $0.name, phone: $0.phone) },
            professionals: plan.professionals.map { SafetyPlanPersonDTO(name: $0.name, phone: $0.phone) },
            safePlace: plan.safePlace)
    }
}
