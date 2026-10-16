import APIClient
import Domain
import Foundation
import Observation

/**
 One debt guide (PED-08, PED-13, PED-14, PED-15): static words from the String Catalog, and buttons
 whose numbers and sites come from `GET /care/contacts` through CareContactsModel (the shipped list
 at once and whenever the server cannot be reached). A site opens in the browser, a number in the phone app or WhatsApp; Susun Naskah
 Keringanan opens the negotiation script.
 */
@MainActor
@Observable
package final class DebtGuideModel {
    /** Where a button or link goes. */
    package enum Destination: Equatable, Sendable {
        /** A `tel:` or `https:` link handed to the system. */
        case link(URL)
        /** A screen of the app. */
        case route(AppRoute)
    }

    /** The guide shown. */
    package let guide: DebtGuide
    /** Loading, then the contacts: the server's, or the shipped ones. */
    package private(set) var phase: ScreenPhase<CareContactList> = .loading

    @ObservationIgnored private let contacts: CareContactsModel

    /** The screen of `guide`. */
    package init(guide: DebtGuide, care: any CareService) {
        self.guide = guide
        contacts = CareContactsModel(service: care)
    }

    /** Loads the contacts; a failure falls back to the shipped list, so the guide always shows. */
    package func load() async {
        await contacts.load()
        phase = .loaded(contacts.contacts)
    }

    /** Where `action` goes; nil when its contact lacks that number or site. */
    package func destination(_ action: DebtGuideAction) -> Destination? {
        let url: URL?
        switch action {
        case .negotiationScript: return .route(.negotiationScript)
        case .callOJK: url = contacts.contact(.ojk157)?.callURL
        case .whatsAppOJK: url = contacts.contact(.ojk157)?.whatsAppURL(message: nil)
        case .reportToSatgas: url = contacts.contact(.satgasPasti)?.website
        case .openLapsSjk: url = contacts.contact(.lapsSjk)?.website
        }
        return url.map(Destination.link)
    }
}
