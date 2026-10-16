import APIClient
import Domain

/** Kira Peduli's contacts over the API client. */
package struct LiveCareService: CareService {
    private let api: KiraAPI

    /** Calls through `api`. */
    package init(api: KiraAPI) {
        self.api = api
    }

    /** `GET /care/contacts`. */
    package func contacts() async throws -> CareContactList {
        try await api.listCareContacts()
    }
}
