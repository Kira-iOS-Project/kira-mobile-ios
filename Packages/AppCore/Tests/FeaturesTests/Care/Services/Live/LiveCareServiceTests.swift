import APIClient
import Domain
import Foundation
import Testing

@testable import Features

@Suite("LiveCareService")
struct LiveCareServiceTests {
    @Test("GET /care/contacts becomes the Domain's list")
    func contacts() async throws {
        let (api, transport) = KiraAPI.routed(["GET /api/care/contacts": ok(contactsJSON)])
        let list = try await LiveCareService(api: api).contacts()
        #expect(list.contact(.psc119)?.callURL?.absoluteString == "tel:119")
        #expect(list.contact(.kiraCare) == nil)
        #expect(await transport.routes == ["GET /api/care/contacts"])
    }

    @Test("a lost session, an unknown contact key or a lost connection is thrown, so the shipped list stays")
    func failures() async {
        let (expired, _) = KiraAPI.routed(["GET /api/care/contacts": problem("AUTH_SESSION_INVALID", status: 401)])
        await #expect(throws: AppProblem.self) { try await LiveCareService(api: expired).contacts() }
        let unknown =
            #"{"verifiedOn":"2026-10-01","contacts":[{"key":"sejiwa","name":"S","phone":"119","#
            + #""extension":null,"whatsapp":null,"url":null,"note":"n"}]}"#
        let (odd, _) = KiraAPI.routed(["GET /api/care/contacts": ok(unknown)])
        await #expect(throws: (any Error).self) { try await LiveCareService(api: odd).contacts() }
        let (down, _) = KiraAPI.routed(["GET /api/care/contacts": problem("INTERNAL_ERROR", status: 500)])
        await #expect(throws: (any Error).self) { try await LiveCareService(api: down).contacts() }

        let model = await CareContactsModel(service: LiveCareService(api: down))
        await model.load()
        #expect(await model.contacts == .shipped)
    }
}

private let contactsJSON = """
    {"verifiedOn":"2026-10-01","contacts":[
    {"key":"psc119","name":"PSC 119","phone":"119","extension":null,"whatsapp":null,"url":null,"note":"n"}]}
    """
