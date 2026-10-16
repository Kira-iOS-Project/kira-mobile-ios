import Foundation
import OpenAPIRuntime

/** The account operations' outputs, mapped to values or to the problem they carry. */

/** The largest export the app reads: well above a year of transactions. */
private let exportLimit = 10 * 1024 * 1024

extension Operations.GetMe.Output {
    func profile() throws -> Profile {
        switch self {
        case .ok(let response): return try Profile(try response.body.json)
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .undocumented: throw AppProblem()
        }
    }
}

extension Operations.UpdateMe.Output {
    func profile() throws -> Profile {
        switch self {
        case .ok(let response): return try Profile(try response.body.json)
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .unprocessableContent(let response): throw try response.body.applicationProblemJson
        case .undocumented: throw AppProblem()
        }
    }
}

extension Operations.GetConsents.Output {
    func consents() throws -> Consents {
        switch self {
        case .ok(let response): return try Consents(try response.body.json)
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .undocumented: throw AppProblem()
        }
    }
}

extension Operations.UpdateConsents.Output {
    func consents() throws -> Consents {
        switch self {
        case .ok(let response): return try Consents(try response.body.json)
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .unprocessableContent(let response): throw try response.body.applicationProblemJson
        case .undocumented: throw AppProblem()
        }
    }
}

extension Operations.ExportData.Output {
    func csv() async throws -> Data {
        switch self {
        case .ok(let response): return try await Data(collecting: try response.body.csv, upTo: exportLimit)
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .undocumented: throw AppProblem()
        }
    }
}

extension Operations.EmailDataExport.Output {
    func done() throws {
        switch self {
        case .accepted: return
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .serviceUnavailable(let response): throw try response.body.applicationProblemJson
        case .undocumented: throw AppProblem()
        }
    }
}

extension Operations.DeleteAccount.Output {
    func done() throws {
        switch self {
        case .noContent: return
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .unprocessableContent(let response): throw try response.body.applicationProblemJson
        case .undocumented: throw AppProblem()
        }
    }
}
