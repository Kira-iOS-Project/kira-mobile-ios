import APIClient
import Domain
import Foundation

/**
 What Kira Peduli tells the server without the person waiting for it or ever seeing it fail: that a
 crisis signal happened (PED-02) and that a check-in is no longer wanted (PED-05, Tidak Perlu).
 Each waits in memory, in order, until the server takes it; one that fails stays, with those after
 it, for the next try. The queue lives as long as Catat's model: an item still waiting when the app
 is closed is lost, so a cancel lost that way lets its greeting show once more. Keeping the queue
 on the device is a known follow-up.
 */
@MainActor
final class CareOutbox {
    /** One thing to tell the server. */
    enum Item: Equatable {
        /** `POST /care/signals`. */
        case signal(CareSignalLevel, CareSignalSource)
        /** `DELETE /care/check-ins/{id}`. */
        case cancel(checkInId: String)
    }

    private let service: any CheckInService
    private var items: [Item] = []
    private var isSending = false

    /** The outbox over `service`. */
    init(service: any CheckInService) {
        self.service = service
    }

    /** Whether the cancel of `checkInId` is still waiting. */
    func cancels(_ checkInId: String) -> Bool {
        items.contains(.cancel(checkInId: checkInId))
    }

    /** Queues `item` after the others; `send()` tells the server. */
    func add(_ item: Item) {
        items.append(item)
    }

    /** Sends the waiting items in order, stopping at the first that does not arrive. */
    func send() async {
        guard !isSending else { return }
        isSending = true
        defer { isSending = false }
        while let item = items.first {
            guard await deliver(item) else { return }
            items.removeFirst()
        }
    }

    /** Whether the server took `item`; a check-in already gone counts as cancelled. */
    private func deliver(_ item: Item) async -> Bool {
        do {
            switch item {
            case .signal(let level, let source): try await service.recordSignal(level, source: source)
            case .cancel(let id): try await service.cancel(id: id)
            }
            return true
        } catch let problem as AppProblem where problem.knownCode == .careCheckInNotFound {
            return true
        } catch {
            return false
        }
    }
}
