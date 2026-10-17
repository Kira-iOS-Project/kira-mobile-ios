import APIClient
import Domain
import Foundation
import Testing

@testable import Features

@Suite("LiveLegalityService")
struct LiveLegalityServiceTests {
    @Test("GET /legality maps the matches and the list's date, source and size")
    func search() async throws {
        let (api, transport) = KiraAPI.routed(["GET /api/legality": ok(searchJSON)])
        let search = try await LiveLegalityService(api: api).search("kredit pintar")
        #expect(await transport.routes == ["GET /api/legality"])
        #expect(search.asOf == CalendarDay(year: 2026, month: 7, day: 31) && search.listed == 94)
        let lender = try #require(search.results.first)
        #expect(lender.app == "Kredit Pintar" && lender.license == "KEP-83/D.05/2019" && !lender.isSharia)
        #expect(lender.licensedOn == CalendarDay(year: 2019, month: 9, day: 30))
        #expect(lender.website?.host() == "www.kreditpintar.com")
        #expect(search.results.last?.isSharia == true)
    }

    @Test("a short query and an unreadable day are thrown as problems")
    func failures() async {
        let short = KiraAPI.routed(["GET /api/legality": problem("VALIDATION_FAILED", status: 422)])
        let refused = await #expect(throws: AppProblem.self) {
            try await LiveLegalityService(api: short.api).search("a")
        }
        #expect(refused?.knownCode == .validationFailed)
        let badDay = searchJSON.replacingOccurrences(of: "2026-07-31", with: "31 Juli")
        let garbled = KiraAPI.routed(["GET /api/legality": ok(badDay)])
        await #expect(throws: AppProblem.self) { try await LiveLegalityService(api: garbled.api).search("kredit") }
        let badLender = searchJSON.replacingOccurrences(of: "2019-09-30", with: "x")
        let lender = KiraAPI.routed(["GET /api/legality": ok(badLender)])
        await #expect(throws: AppProblem.self) { try await LiveLegalityService(api: lender.api).search("kredit") }
        let unauthorized = KiraAPI.routed(["GET /api/legality": problem("AUTH_UNAUTHENTICATED", status: 401)])
        await #expect(throws: AppProblem.self) { try await LiveLegalityService(api: unauthorized.api).search("ab") }
        let other = KiraAPI.routed(["GET /api/legality": problem("INTERNAL_ERROR", status: 500)])
        await #expect(throws: AppProblem.self) { try await LiveLegalityService(api: other.api).search("ab") }
    }
}

private let searchJSON =
    #"{"asOf":"2026-07-31","source":"https://ojk.go.id/x","listed":94,"results":["#
    + #"{"company":"PT Kredit Pintar Indonesia","app":"Kredit Pintar","license":"KEP-83/D.05/2019","#
    + #""licensedOn":"2019-09-30","type":"conventional","website":"https://www.kreditpintar.com/"},"#
    + #"{"company":"PT Dana Syariah Indonesia","app":"DANA SYARIAH","license":"KEP-10/D.05/2021","#
    + #""licensedOn":"2021-02-23","type":"sharia","website":"http://danasyariah.id"}]}"#
