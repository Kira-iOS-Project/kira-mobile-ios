import APIClient
import Domain
import Foundation
import Observation

/**
 Beranda (BRD-01, BRD-02, BRD-03): loads `GET /home`, greets by the WIB time of day, hides amounts
 behind the eye for the rest of the session, and lets "Nanti Saja" put the step away until the
 next load.
 */
@MainActor
@Observable
package final class HomeModel {
    package private(set) var phase: ScreenPhase<HomeOverview> = .loading
    /** Whether amounts show as Rp••••••. */
    package private(set) var isMasked = false
    /** Whether "Nanti Saja" put the step card away. */
    package private(set) var isStepDismissed = false

    private let service: any HomeService
    private let now: @Sendable () -> Date
    /** Set once the person taps the eye, so a reload keeps their choice for this session. */
    private var maskedThisSession: Bool?

    package init(service: any HomeService, now: @escaping @Sendable () -> Date = { Date() }) {
        self.service = service
        self.now = now
    }

    /** The part of the day the greeting names, now in WIB. */
    package var dayPart: DayPart { DayPart(at: now()) }

    /** Loads Beranda; a failure keeps nothing of an earlier load. */
    package func load() async {
        do {
            let overview = try await service.home()
            isMasked = maskedThisSession ?? overview.hideBalances
            isStepDismissed = false
            phase = .loaded(overview)
        } catch {
            phase = .failed(error as? AppProblem ?? AppProblem())
        }
    }

    /** Shows or hides amounts, and asks the API to remember it; the session keeps it either way. */
    package func toggleMasked() async {
        isMasked.toggle()
        maskedThisSession = isMasked
        try? await service.setHideBalances(isMasked)
    }

    /** "Nanti Saja": puts the step card away until the next load. */
    package func dismissStep() {
        isStepDismissed = true
    }

    /** The step to show, unless it was put away. */
    package var visibleStep: ScoreStep? {
        isStepDismissed ? nil : phase.value?.step
    }
}
