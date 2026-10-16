import APIClient
import Domain
import Foundation
import Observation

/** Ajukan Beasiswa (AKN-10, AKN-10b): at least one situation and an optional story. */
@MainActor
@Observable
package final class ScholarshipApplyModel {
    /** The longest story the API takes. */
    package static let storyLimit = 1000

    /** The account email listed under Ikut Terkirim, once loaded. */
    package private(set) var phase: ScreenPhase<String> = .loading
    /** The situations picked. */
    package private(set) var situations: Set<ScholarshipSituation> = []
    /** The story, optional. */
    package var story = ""
    /** Whether the application is on its way. */
    package private(set) var isSending = false
    /** The application once sent: the "Pengajuan Terkirim" dialog shows. */
    package var sent: ScholarshipApplication?
    /** The problem of a refused application. */
    package private(set) var sendProblem: AppProblem?

    private let service: any PlansService

    /** The form, with nothing picked. */
    package init(service: any PlansService) {
        self.service = service
    }

    /**
     Whether Kirim Pengajuan can be tapped: the account email loaded (it is what the form says is
     sent along), a situation picked and the story within its limit.
     */
    package var canSend: Bool {
        phase.value != nil && !situations.isEmpty && story.count <= Self.storyLimit && !isSending
    }

    /** Whether the story is longer than the API takes. */
    package var isStoryTooLong: Bool { story.count > Self.storyLimit }

    /** Loads the account email, or loads it again after a failure; the picks and the story stay. */
    package func load() async {
        phase = .loading
        do {
            phase = .loaded(try await service.accountEmail())
        } catch {
            phase = .failed(plansProblem(error))
        }
    }

    /** Picks or unpicks a situation. */
    package func toggle(_ situation: ScholarshipSituation) {
        if situations.contains(situation) {
            situations.remove(situation)
        } else {
            situations.insert(situation)
        }
    }

    /** Sends the application, situations in the form's order and a blank story left out. */
    package func send() async {
        guard canSend else { return }
        isSending = true
        sendProblem = nil
        let picked = ScholarshipSituation.allCases.filter(situations.contains)
        let trimmed = story.trimmingCharacters(in: .whitespacesAndNewlines)
        do {
            sent = try await service.apply(situations: picked, story: trimmed.isEmpty ? nil : trimmed)
        } catch {
            sendProblem = plansProblem(error)
        }
        isSending = false
    }
}
