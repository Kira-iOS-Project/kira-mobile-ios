import Foundation
import OpenAPIRuntime

/** The account operations' outputs, mapped to values or to the problem they carry. */

/** The largest export the app reads: well above a year of transactions. */
private let exportLimit = 10 * 1024 * 1024

extension Operations.GetMe.Output {
    func profile() throws -> MeDTO {
        switch self {
        case .ok(let response): return try MeDTO(try response.body.json)
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .default(_, let response): throw try response.body.applicationProblemJson
        }
    }
}

extension Operations.UpdateMe.Output {
    func profile() throws -> MeDTO {
        switch self {
        case .ok(let response): return try MeDTO(try response.body.json)
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .unprocessableContent(let response): throw try response.body.applicationProblemJson
        case .default(_, let response): throw try response.body.applicationProblemJson
        }
    }
}

extension Operations.GetConsents.Output {
    func consents() throws -> ConsentsDTO {
        switch self {
        case .ok(let response): return try ConsentsDTO(try response.body.json)
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .default(_, let response): throw try response.body.applicationProblemJson
        }
    }
}

extension Operations.UpdateConsents.Output {
    func consents() throws -> ConsentsDTO {
        switch self {
        case .ok(let response): return try ConsentsDTO(try response.body.json)
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .unprocessableContent(let response): throw try response.body.applicationProblemJson
        case .default(_, let response): throw try response.body.applicationProblemJson
        }
    }
}

extension Operations.ExportData.Output {
    func csv() async throws -> Data {
        switch self {
        case .ok(let response): return try await Data(collecting: try response.body.csv, upTo: exportLimit)
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .default(_, let response): throw try response.body.applicationProblemJson
        }
    }
}

extension Operations.EmailDataExport.Output {
    func done() throws {
        switch self {
        case .accepted: return
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .tooManyRequests(let response): throw try response.body.applicationProblemJson
        case .serviceUnavailable(let response): throw try response.body.applicationProblemJson
        case .default(_, let response): throw try response.body.applicationProblemJson
        }
    }
}

extension Operations.DeleteAccount.Output {
    func done() throws {
        switch self {
        case .noContent: return
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .unprocessableContent(let response): throw try response.body.applicationProblemJson
        case .default(_, let response): throw try response.body.applicationProblemJson
        }
    }
}
