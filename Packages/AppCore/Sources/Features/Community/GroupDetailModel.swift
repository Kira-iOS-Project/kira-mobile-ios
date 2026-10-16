import APIClient
import Domain
import Observation

/**
 Detail Grup (KOM-02) and the way in: "Gabung Grup" shows Aturan Komunitas (KOM-03) unless the
 current rules are accepted, then asks the API for the invite and confirms the outside link
 (KOM-04) every time. "Laporkan Grup" (KOM-05) is always there. A submit that fails closes its
 sheet and shows the failure dialog here; Coba Lagi reopens that sheet with its input and repeats.
 */
@MainActor @Observable
package final class GroupDetailModel {
    /** What Coba Lagi repeats. */
    package enum Attempt: Equatable, Sendable {
        /** "Setuju dan Lanjut". */
        case acceptRules
        /** Asking for the invite. */
        case join
        /** "Kirim Laporan". */
        case report
    }

    /** Loading, loaded or failed (404 when the group is gone or suspended). */
    package private(set) var phase = ScreenPhase<CommunityGroup>.loading
    /** Whether the Aturan Komunitas sheet is open. */
    package var showsRules = false
    /** "Aku sudah membaca dan setuju". */
    package var rulesAgreed = false
    /** The invite the Tautan Keluar sheet confirms, nil when the sheet is closed. */
    package var invite: GroupInvite?
    /** Whether the Laporkan Grup sheet is open. */
    package var showsReport = false
    /** Whether "Laporan Terkirim" is showing. */
    package var showsReportSent = false
    /** The last failure, shown as a dialog, and what Coba Lagi repeats. */
    package private(set) var failure: (failure: CommunityFailure, attempt: Attempt)?
    /** Whether a rules or join request is on its way. */
    package private(set) var isWorking = false
    /** The report's form, kept while the sheet is closed. */
    package let reportForm: GroupReportModel
    /** The group's id. */
    package let groupID: String
    private let service: any CommunityService

    /** The detail of group `groupID`, through `service`. */
    package init(groupID: String, service: any CommunityService) {
        self.groupID = groupID
        self.service = service
        reportForm = GroupReportModel(groupID: groupID, service: service)
    }

    /** Loads the group, or again after a failure. */
    package func load() async {
        if phase.value == nil { phase = .loading }
        do {
            phase = .loaded(try await service.group(id: groupID))
        } catch {
            if phase.value == nil { phase = .failed(CommunityFailure(error).screenProblem) }
        }
    }

    /** "Gabung Grup": the rules first when not accepted, else the invite. */
    package func join() async {
        guard let group = phase.value, !isWorking else { return }
        if group.rulesAccepted {
            await requestInvite()
        } else {
            rulesAgreed = false
            showsRules = true
        }
    }

    /** "Setuju dan Lanjut": keeps the acceptance with the rules' version, then asks for the invite. */
    package func acceptRules() async {
        guard rulesAgreed, let group = phase.value, !isWorking else { return }
        isWorking = true
        do {
            try await service.acceptRules(version: CommunityRules.version)
            phase = .loaded(group.acceptingRules())
            showsRules = false
            isWorking = false
            await requestInvite()
        } catch {
            isWorking = false
            showsRules = false
            failure = (CommunityFailure(error), .acceptRules)
        }
    }

    /** "Laporkan Grup". */
    package func report() {
        showsReport = true
    }

    /** "Kirim Laporan": closes the sheet, then shows "Laporan Terkirim" or the failure. */
    package func sendReport() async {
        guard let outcome = await reportForm.send() else { return }
        showsReport = false
        switch outcome {
        case .sent: showsReportSent = true
        case .failed(let failure): self.failure = (failure, .report)
        }
    }

    /** Whether Coba Lagi can help: not for a report already open or a link still being checked. */
    package var canRetry: Bool {
        guard case .problem(let problem) = failure?.failure else { return true }
        return problem.knownCode != .communityReportDuplicate && problem.knownCode != .communityLinkUnavailable
    }

    /** Tutup on the failure dialog. */
    package func dismissFailure() {
        failure = nil
    }

    /** Coba Lagi: reopens the failed sheet with its input and repeats the submit. */
    package func retry() async {
        guard let attempt = failure?.attempt else { return }
        failure = nil
        switch attempt {
        case .acceptRules:
            showsRules = true
            await acceptRules()
        case .join:
            await requestInvite()
        case .report:
            showsReport = true
            await sendReport()
        }
    }

    private func requestInvite() async {
        isWorking = true
        defer { isWorking = false }
        do {
            invite = try await service.join(groupID: groupID)
        } catch let problem as AppProblem where problem.knownCode == .communityRulesNotAccepted {
            rulesAgreed = false
            showsRules = true
        } catch let problem as AppProblem where problem.knownCode == .communityGroupNotFound {
            phase = .failed(problem)
        } catch {
            failure = (CommunityFailure(error), .join)
        }
    }
}
