import APIClient
import Domain
import Observation

/**
 Laporkan Grup (KOM-05, KOM-05d): one reason, a story that "Lainnya" requires, and "Kirim Laporan".
 Sent shows "Laporan Terkirim" (KOM-05b); a dropped connection shows "Laporan Belum Terkirim"
 (KOM-05c) with Coba Lagi, and what was typed stays.
 */
@MainActor @Observable
package final class GroupReportModel {
    /** The report as filled in. */
    package var report = GroupReport()
    /** Whether the report is on its way. */
    package private(set) var isSending = false
    /** Whether "Laporan Terkirim" is showing. */
    package var showsSent = false
    /** Why the last send failed, shown as a dialog; the report stays. */
    package var failure: CommunityFailure?
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

    /** "Kirim Laporan", and "Coba Lagi" on the failure dialog. */
    package func send() async {
        guard report.canSend, let reason = report.reason, !isSending else { return }
        isSending = true
        defer { isSending = false }
        do {
            try await service.report(groupID: groupID, reason: reason, story: report.trimmedStory)
            sent()
        } catch let problem as AppProblem
            where problem.knownCode == .communityReportDuplicate && lastSendLostConnection
        {
            /** The send before landed and only its answer was lost: the report exists. */
            sent()
        } catch {
            let failure = CommunityFailure(error)
            lastSendLostConnection = failure == .connection
            self.failure = failure
        }
    }

    private func sent() {
        lastSendLostConnection = false
        failure = nil
        showsSent = true
    }
}
