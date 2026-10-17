import Domain

/** Cek Legalitas's search (REN-09). */
package protocol LegalityService: Sendable {
    /** `GET /legality` (`searchLegality`): OJK's licensed fintech lenders matching `query`. */
    func search(_ query: String) async throws -> LegalitySearch
}
