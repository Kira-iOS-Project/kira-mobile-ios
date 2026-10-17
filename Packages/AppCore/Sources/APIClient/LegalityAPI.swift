import Domain
import Foundation

/** Cek Legalitas (tag Rencana): OJK's licensed fintech lenders, searched on the server. */
extension KiraAPI {
    /** The lenders matching every word of `query`; 422 for fewer than two characters (`GET /api/legality`). */
    package func searchLegality(_ query: String) async throws -> LegalitySearch {
        try await client.searchLegality(query: .init(q: query)).search()
    }
}

extension Operations.SearchLegality.Output {
    func search() throws -> LegalitySearch {
        switch self {
        case .ok(let response): return try LegalitySearch(try response.body.json)
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .unprocessableContent(let response): throw try response.body.applicationProblemJson
        case .default(_, let response): throw try response.body.applicationProblemJson
        }
    }
}

extension LegalitySearch {
    /** A day the app cannot read is the generic problem. */
    init(_ dto: Components.Schemas.LegalitySearch) throws {
        guard let asOf = CalendarDay(iso: dto.asOf) else { throw AppProblem() }
        self.init(
            results: try dto.results.map(LicensedLender.init), asOf: asOf, source: URL(string: dto.source),
            listed: dto.listed)
    }
}

extension LicensedLender {
    init(_ dto: Components.Schemas.LicensedLender) throws {
        guard let licensedOn = CalendarDay(iso: dto.licensedOn) else { throw AppProblem() }
        self.init(
            company: dto.company, app: dto.app, license: dto.license, licensedOn: licensedOn,
            isSharia: dto._type == .sharia, website: URL(string: dto.website))
    }
}
