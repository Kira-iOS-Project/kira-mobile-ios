import APIClient
import Domain
import Observation

/**
 Beasiswa Kira (AKN-09, AKN-10c, AKN-10d): the explanation, or the application's status once one is
 open. Tarik Pengajuan takes it back and shows the explanation again.
 */
@MainActor
@Observable
package final class ScholarshipModel {
    /** The overview once loaded. */
    package private(set) var phase: ScreenPhase<ScholarshipOverview> = .loading
    /** Whether Tarik Pengajuan is on its way. */
    package private(set) var isWithdrawing = false
    /** The problem of a refused withdrawal. */
    package private(set) var withdrawProblem: AppProblem?

    private let service: any PlansService

    /** The screen. */
    package init(service: any PlansService) {
        self.service = service
    }

    /** Loads eligibility, the quota and the application. */
    package func load() async {
        phase = .loading
        await refresh()
    }

    /** Takes the open application back, then shows the explanation again. */
    package func withdraw() async {
        isWithdrawing = true
        withdrawProblem = nil
        do {
            try await service.withdrawApplication()
            await refresh()
        } catch {
            withdrawProblem = plansProblem(error)
        }
        isWithdrawing = false
    }

    private func refresh() async {
        do {
            phase = .loaded(try await service.scholarship())
        } catch {
            phase = .failed(plansProblem(error))
        }
    }
}
