/**
 The crisis signal and the check-in without the API, for previews and `-KiraScreen`: signals and
 schedules are taken and forgotten; `isDue` answers the board's check-in as due (CheckInChat).
 */
import Domain
import Features
import Foundation

struct PreviewCheckInService: CheckInService {
    var isDue = false

    func recordSignal(_: CareSignalLevel, source _: CareSignalSource) {}

    func schedule(after delay: CheckInDelay) -> CheckIn {
        CheckIn(id: "preview-check-in-\(delay.hours)", dueAt: .distantFuture)
    }

    func due() -> CheckIn? {
        isDue ? CheckIn(id: "preview-check-in", dueAt: .distantPast) : nil
    }

    func markSeen(id _: String) {}
}
