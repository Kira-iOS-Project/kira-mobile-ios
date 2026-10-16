import APIClient
import Domain
import Observation

/**
 Detail Grup (KOM-02) and the way in: "Gabung Grup" shows Aturan Komunitas (KOM-03) unless the
 current rules are accepted, then asks the API for the invite and confirms the outside link
 (KOM-04) every time. "Laporkan Grup" is always there, also for those who never joined.
 */
@MainActor @Observable
package final class GroupDetailModel {
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
    /** A failed join, shown as a dialog over the screen. */
    package var failure: CommunityFailure?
    /** Whether a rules or join request is on its way. */
    package private(set) var isWorking = false
    private let groupID: String
    private let service: any CommunityService

    /** The detail of group `groupID`, through `service`. */
    package init(groupID: String, service: any CommunityService) {
        self.groupID = groupID
        self.service = service
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
            askForRules()
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
            failure = CommunityFailure(error)
        }
    }

    /** "Laporkan Grup". */
    package func report() {
        showsReport = true
    }

    private func askForRules() {
        rulesAgreed = false
        showsRules = true
    }

    private func requestInvite() async {
        isWorking = true
        defer { isWorking = false }
        do {
            invite = try await service.join(groupID: groupID)
        } catch let problem as AppProblem where problem.knownCode == .communityRulesNotAccepted {
            askForRules()
        } catch let problem as AppProblem where problem.knownCode == .communityGroupNotFound {
            phase = .failed(problem)
        } catch {
            failure = CommunityFailure(error)
        }
    }
}
