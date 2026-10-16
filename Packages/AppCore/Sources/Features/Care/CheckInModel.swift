import Domain
import Observation

/**
 Check-in Lanjutan (PED-05): after a heavy moment Kira asks to greet again in 24, 48 or 72 hours,
 Besok chosen first. Ya, Sapa Aku schedules the greeting; Tidak Perlu and the close button go back
 to the chat with nothing scheduled. A failed request closes the sheet and hands the failure and
 the choice to the chat, whose dialog offers Coba Lagi (the owner's rule for a submit in a sheet).
 */
@MainActor
@Observable
package final class CheckInModel {
    /** The chosen delay. */
    package var delay: CheckInDelay
    /** Whether the request is on its way. */
    package internal(set) var isSaving = false
    private let service: any CheckInService
    private let onFinish: () -> Void
    private let onFailure: (CheckInFailure) -> Void

    /**
     The offer on `service` with `delay` chosen; `onFinish` closes it, `onFailure` closes it with
     what failed and the choice to try again with.
     */
    init(
        service: any CheckInService, delay: CheckInDelay, onFinish: @escaping () -> Void,
        onFailure: @escaping (CheckInFailure) -> Void
    ) {
        self.service = service
        self.delay = delay
        self.onFinish = onFinish
        self.onFailure = onFailure
    }

    /** Ya, Sapa Aku. */
    package func schedule() async {
        guard !isSaving else { return }
        isSaving = true
        defer { isSaving = false }
        do {
            _ = try await service.schedule(after: delay)
            onFinish()
        } catch {
            onFailure(CheckInFailure(failure: RecordFailure(error), delay: delay))
        }
    }

    /** Tidak Perlu, or the close button: nothing is scheduled. */
    package func decline() {
        onFinish()
    }
}

/** Why scheduling the check-in failed, and the delay Coba Lagi keeps. */
package struct CheckInFailure: Equatable, Sendable {
    /** The connection, or the problem the API answered with. */
    package let failure: RecordFailure
    /** The delay the person chose. */
    package let delay: CheckInDelay
}
