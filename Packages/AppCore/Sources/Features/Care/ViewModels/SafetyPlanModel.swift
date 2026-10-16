import APIClient
import Domain
import Observation

/**
 Rencana Keselamatanku (PED-10): the five parts as saved, each with a pencil that opens the form
 (PED-10c). A plan never saved is an empty plan, not a failure (`GET` answers 404). Parts 3 and 4
 list their contacts, each a number the person can tap to call.
 */
@MainActor
@Observable
package final class SafetyPlanModel {
    /** The plan once loaded, empty when none was saved. */
    package private(set) var phase: ScreenPhase<SafetyPlan> = .loading
    /** The open form; nil while the plan shows. */
    package var form: SafetyPlanFormModel?

    private let service: any CareToolsService

    /** A plan read through `service`. */
    package init(service: any CareToolsService) {
        self.service = service
    }

    /** Loads the saved plan, or the empty one. */
    package func load() async {
        do {
            phase = .loaded(try await service.safetyPlan() ?? .empty)
        } catch {
            phase = .failed(careProblem(error))
        }
    }

    /** Opens the form on the plan as it shows, focused on `part`. */
    package func edit(_ part: SafetyPlanPart) {
        let plan = phase.value ?? .empty
        form = SafetyPlanFormModel(plan: plan, focus: part, service: service) { [weak self] saved in
            self?.phase = .loaded(saved)
        }
    }
}

/** A part of the plan, in the board's order. */
package enum SafetyPlanPart: Int, CaseIterable, Hashable, Sendable {
    /** 1. Tanda Aku Mulai Berat. */
    case warningSigns = 1
    /** 2. Hal yang Menenangkanku. */
    case calmingThings
    /** 3. Orang yang Bisa Kuhubungi. */
    case people
    /** 4. Layanan Profesional. */
    case professionals
    /** 5. Tempat Aku Merasa Aman. */
    case safePlace
}
