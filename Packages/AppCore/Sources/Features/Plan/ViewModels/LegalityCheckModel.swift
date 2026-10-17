import APIClient
import Domain
import Foundation
import Observation

/**
 Cek Legalitas (REN-09): the name typed is searched in OJK's list of licensed fintech lenders when
 the person submits it. Kira decides nothing: a match says the name is on that list, no match says
 only that it is not, as of the list's date. The words typed stay in this model, never stored.
 */
@MainActor
@Observable
package final class LegalityCheckModel {
    /** Where the search stands. */
    package enum Phase: Hashable, Sendable {
        /** Nothing searched since the field last changed. */
        case idle
        /** The search is on its way. */
        case searching
        /** The answer: matches, or none (`results` empty), for `query`. */
        case answered(query: String, LegalitySearch)
        /** The API refused or could not be reached. */
        case failed(AppProblem)
    }

    /** The fewest characters a search sends. */
    package static let minimumLength = 2

    /** What is typed; a change clears the last answer. */
    package var query = "" {
        didSet { if query != oldValue, phase != .searching { phase = .idle } }
    }
    /** Idle, searching, the answer, or the problem. */
    package private(set) var phase = Phase.idle
    /** Whether the answer's dialog is up: each search's outcome is said once, in a dialog. */
    package private(set) var showsResult = false

    @ObservationIgnored private let service: any LegalityService

    /** A model searching through `service`. */
    package init(service: any LegalityService) {
        self.service = service
    }

    /** Whether the typed words are long enough to search. */
    package var canSearch: Bool {
        query.trimmingCharacters(in: .whitespacesAndNewlines).count >= Self.minimumLength
    }

    /** Searches what is typed; too short does nothing, one search at a time. */
    package func search() async {
        let text = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard canSearch, phase != .searching else { return }
        phase = .searching
        do {
            phase = .answered(query: text, try await service.search(text))
        } catch {
            phase = .failed(AppProblem(error))
        }
        showsResult = true
    }

    /** The answer's dialog closed; the matches stay listed under the field. */
    package func resultClosed() {
        showsResult = false
    }
}
