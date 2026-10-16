import APIClient
import Domain
import Observation

/**
 Laporkan Grup's form (KOM-05, KOM-05d): one reason, a story that "Lainnya" requires, and the send.
 Detail Grup owns it, so what was typed survives the sheet closing on a failure.
 */
@MainActor @Observable
package final class GroupReportModel {
    /** How a send ended. */
    package enum Outcome: Equatable, Sendable {
        /** The report reached the moderation team. */
        case sent
        /** It did not; the report stays as typed. */
        case failed(CommunityFailure)
    }

    /** The report as filled in. */
    package var report = GroupReport()
    /** Whether the report is on its way. */
    package private(set) var isSending = false
    private var lastSendLostConnection = false
    private let groupID: String
    private let service: any CommunityService

    /** A report on group `groupID`, sent through `service`. */
    package init(groupID: String, service: any CommunityService) {
        self.groupID = groupID
        self.service = service
    }

    /** Chooses `reason`; "Lainnya" makes the story required. */
    package func choose(_ reason: GroupReportReason) {
        report.reason = reason
    }

    /** Sends the report; nil when it cannot be sent yet (no reason, a missing story) or one is on its way. */
    package func send() async -> Outcome? {
        guard report.canSend, let reason = report.reason, !isSending else { return nil }
        isSending = true
        defer { isSending = false }
        do {
            try await service.report(groupID: groupID, reason: reason, story: report.trimmedStory)
            return sent()
        } catch let problem as AppProblem where landedBefore(problem) {
            /** The send before landed and only its answer was lost: the report exists. */
            return sent()
        } catch {
            let failure = CommunityFailure(error)
            lastSendLostConnection = failure == .connection
            return .failed(failure)
        }
    }

    /** Whether `problem` says the previous send, whose answer was lost, landed. */
    private func landedBefore(_ problem: AppProblem) -> Bool {
        problem.knownCode == .communityReportDuplicate && lastSendLostConnection
    }

    private func sent() -> Outcome {
        lastSendLostConnection = false
        report = GroupReport()
        return .sent
    }
}
