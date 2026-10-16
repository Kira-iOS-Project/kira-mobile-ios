import APIClient
import Domain
import Observation

/**
 The verified contacts of Kira Peduli (PED-01), its sheet over the chat (PED-03) and the message
 to Layanan Kira (PED-04). Help never waits on the network and never fails: the shipped list shows
 at once, the server's replaces it when it arrives, and a failed load keeps the shipped one.
 */
@MainActor
@Observable
package final class CareContactsModel {
    /** Where the contacts on screen came from. */
    package enum Source: Sendable, Equatable {
        /** The list the app ships, before the server answers or when it cannot be reached. */
        case shipped
        /** The server's list. */
        case server
    }

    /** The contacts to show. */
    package private(set) var contacts: CareContactList = .shipped
    /** Where `contacts` came from. */
    package private(set) var source: Source = .shipped
    /** The problem of the last failed load, kept for the log; the screen still shows the shipped list. */
    package private(set) var problem: AppProblem?

    private let service: any CareService

    /** The contacts, from `service`. */
    package init(service: any CareService) {
        self.service = service
    }

    /** Loads the server's list, keeping what is on screen when it cannot be reached. */
    package func load() async {
        do {
            contacts = try await service.contacts()
            source = .server
            problem = nil
        } catch {
            problem = AppProblem(error)
        }
    }

    /** The contact of `key`: the server's, or the shipped one when the server's list lacks it. */
    package func contact(_ key: CareContactKey) -> CareContact? {
        contacts.contactOrShipped(key)
    }
}
