import APIClient
import Domain
import Observation

/**
 Detail Grup (KOM-02) and the way in: "Gabung Grup" shows Aturan Komunitas (KOM-03) unless the
 current rules are accepted, then asks the API for the invite and confirms the outside link
 (KOM-04) every time. "Laporkan Grup" (KOM-05) is always there; "Laporan Terkirim" shows over
 its sheet, and Selesai goes back to Komunitas. A submit that fails closes its sheet and shows the
 failure dialog here; Coba Lagi reopens that sheet with its input and repeats, Tutup drops it.
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
    /** Whether "Laporan Terkirim" is showing over the report sheet. */
    package var showsReportSent = false
    /** Selesai was tapped: the sheet closes, then Detail Grup goes back to Komunitas. */
    package private(set) var reportFinished = false
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
        } catch is CancellationError {
            return
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
        } catch is CancellationError {
            isWorking = false
        } catch {
            isWorking = false
            showsRules = false
            let failure = CommunityFailure(error)
            self.failure = (failure, .acceptRules)
            /** The API refused this rules version: what it holds now is loaded again. */
            if failure.kind == .refused { await load() }
        }
    }

    /**
     "Kirim Laporan": "Laporan Terkirim" over the sheet, or the sheet closes on the failure; a gone
     group shows in place of the group, as on joining.
     */
    package func sendReport() async {
        guard let outcome = await reportForm.send() else { return }
        switch outcome {
        case .sent:
            showsReportSent = true
        case .failed(let failure):
            showsReport = false
            if failure.kind == .groupGone {
                phase = .failed(failure.screenProblem)
            } else {
                self.failure = (failure, .report)
            }
        }
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
        } catch is CancellationError {
            return
        } catch {
            let failure = CommunityFailure(error)
            switch failure.kind {
            case .rulesNotAccepted:
                rulesAgreed = false
                showsRules = true
            case .groupGone: phase = .failed(failure.screenProblem)
            case .linkUnavailable, .reportDuplicate, .refused, .other, nil: self.failure = (failure, .join)
            }
        }
    }
}

extension GroupDetailModel {
    /** "Laporkan Grup". */
    package func report() {
        showsReport = true
    }

    /** Selesai on "Laporan Terkirim": the dialog and the sheet close, and the screen goes back. */
    package func finishReport() {
        showsReportSent = false
        reportFinished = true
    }

    /** Whether Coba Lagi can help: not when the same thing sent again cannot work. */
    package var canRetry: Bool {
        failure?.failure.kind?.allowsRetry ?? true
    }

    /** Tutup on the failure dialog: what the failed sheet held is dropped. */
    package func dismissFailure() {
        switch failure?.attempt {
        case .acceptRules: rulesAgreed = false
        case .report: reportForm.report = GroupReport()
        case .join, nil: break
        }
        failure = nil
    }
}
