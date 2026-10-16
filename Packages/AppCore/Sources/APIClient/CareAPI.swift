import Domain
import Foundation

/** Kira Peduli: the verified contacts. */
extension KiraAPI {
    /** The contacts the team verifies every month (`GET /api/care/contacts`). */
    package func listCareContacts() async throws -> CareContactList {
        try await client.listCareContacts().contacts()
    }
}

extension Operations.ListCareContacts.Output {
    func contacts() throws -> CareContactList {
        switch self {
        case .ok(let response): return try CareContactList(try response.body.json)
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .default(_, let response): throw try response.body.applicationProblemJson
        }
    }
}

extension CareContactList {
    /** The list as the API sent it; a day this app cannot read is a problem without a code. */
    init(_ body: Components.Schemas.CareContacts) throws {
        guard let day = CalendarDay(iso: body.verifiedOn) else { throw AppProblem() }
        self.init(verifiedOn: day, contacts: try body.contacts.map(CareContact.init))
    }
}

extension CareContact {
    init(_ body: Components.Schemas.CareContact) throws {
        self.init(
            key: try bridged(body.key), name: body.name, phone: body.phone, phoneExtension: body._extension,
            whatsApp: body.whatsapp, website: body.url.flatMap(URL.init(string:)), note: body.note)
    }
}
