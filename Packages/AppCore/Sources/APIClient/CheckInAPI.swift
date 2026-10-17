/**
 Kira Peduli's crisis signals and check-ins (tag Care; PED-02, PED-05, PED-06). A signal carries
 its level and source only, never the message it was found in.
 */
extension KiraAPI {
    /** Records that a crisis signal happened (`POST /api/care/signals`). */
    package func recordCareSignal(level: CareSignalLevelDTO, source: CareSignalSourceDTO) async throws {
        let body = Components.Schemas.CareSignal(level: try bridged(level), source: try bridged(source))
        try await client.recordCareSignal(body: .json(body)).done()
    }

    /** Asks Kira to greet again after `afterHours` (24, 48 or 72), replacing a pending check-in. */
    package func scheduleCheckIn(afterHours: Int) async throws -> CheckInDTO {
        let body = Components.Schemas.ScheduleCheckIn(afterHours: .init(value1: Double(afterHours)))
        return try await client.scheduleCheckIn(body: .json(body)).checkIn()
    }

    /** The pending check-in whose time has come, or nil (`GET /api/care/check-ins/due`). */
    package func getDueCheckIn() async throws -> CheckInDTO? {
        try await client.getDueCheckIn().due()
    }

    /** Marks a check-in's greeting as shown (`POST /api/care/check-ins/{id}/seen`). */
    package func markCheckInSeen(id: String) async throws {
        try await client.markCheckInSeen(path: .init(id: id)).done()
    }

    /** Cancels a pending check-in (`DELETE /api/care/check-ins/{id}`). */
    package func cancelCheckIn(id: String) async throws {
        try await client.cancelCheckIn(path: .init(id: id)).done()
    }
}

/** A check-in as the API returns it. */
package struct CheckInDTO: Equatable, Sendable {
    /** The check-in's id. */
    package let id: String

    init(_ checkIn: Components.Schemas.CheckIn) {
        id = checkIn.id
    }
}

/** How strong a crisis signal is, in the API's spelling. */
package enum CareSignalLevelDTO: String, CaseIterable, Sendable {
    /** Despair. */
    case concern
    /** Words about ending one's life. */
    case danger
}

/** Where a crisis signal came from, in the API's spelling. */
package enum CareSignalSourceDTO: String, CaseIterable, Sendable {
    /** The Catat chat. */
    case chat
    /** A check-in greeting. */
    case checkIn = "check_in"
}

extension Operations.RecordCareSignal.Output {
    func done() throws {
        switch self {
        case .noContent: return
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .unprocessableContent(let response): throw try response.body.applicationProblemJson
        case .default(_, let response): throw try response.body.applicationProblemJson
        }
    }
}

extension Operations.ScheduleCheckIn.Output {
    func checkIn() throws -> CheckInDTO {
        switch self {
        case .created(let response): return CheckInDTO(try response.body.json)
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .unprocessableContent(let response): throw try response.body.applicationProblemJson
        case .default(_, let response): throw try response.body.applicationProblemJson
        }
    }
}

extension Operations.GetDueCheckIn.Output {
    func due() throws -> CheckInDTO? {
        switch self {
        case .ok(let response): return try response.body.json.checkIn.map { CheckInDTO($0.value1) }
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .default(_, let response): throw try response.body.applicationProblemJson
        }
    }
}

extension Operations.MarkCheckInSeen.Output {
    func done() throws {
        switch self {
        case .noContent: return
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .notFound(let response): throw try response.body.applicationProblemJson
        case .unprocessableContent(let response): throw try response.body.applicationProblemJson
        case .default(_, let response): throw try response.body.applicationProblemJson
        }
    }
}

extension Operations.CancelCheckIn.Output {
    func done() throws {
        switch self {
        case .noContent: return
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .notFound(let response): throw try response.body.applicationProblemJson
        case .unprocessableContent(let response): throw try response.body.applicationProblemJson
        case .default(_, let response): throw try response.body.applicationProblemJson
        }
    }
}
