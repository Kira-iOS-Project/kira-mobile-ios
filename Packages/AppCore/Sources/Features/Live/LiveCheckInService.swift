import APIClient
import Domain

/** The crisis signal and the check-in over the API client. */
package struct LiveCheckInService: CheckInService {
    private let api: KiraAPI

    /** Calls through `api`. */
    package init(api: KiraAPI) {
        self.api = api
    }

    /** `POST /care/signals`. */
    package func recordSignal(_ level: CareSignalLevel, source: CareSignalSource) async throws {
        try await api.recordCareSignal(level: try Bridge.value(level), source: try Bridge.value(source))
    }

    /** `POST /care/check-ins`. */
    package func schedule(after delay: CheckInDelay) async throws -> CheckIn {
        CheckIn(try await api.scheduleCheckIn(afterHours: delay.hours))
    }

    /** `GET /care/check-ins/due`. */
    package func due() async throws -> CheckIn? {
        try await api.getDueCheckIn().map(CheckIn.init)
    }

    /** `POST /care/check-ins/{id}/seen`. */
    package func markSeen(id: String) async throws {
        try await api.markCheckInSeen(id: id)
    }
}

extension CheckIn {
    init(_ dto: CheckInDTO) {
        self.init(id: dto.id, dueAt: dto.dueAt)
    }
}
