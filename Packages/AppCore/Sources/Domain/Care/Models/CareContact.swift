import Foundation

/** The contacts Kira Peduli lists, by the key `GET /care/contacts` sends. */
package enum CareContactKey: String, CaseIterable, Sendable {
    /** Healing119: the health ministry's counsellors, 119 extension 8. */
    case healing119
    /** Layanan Kira Peduli: the Kira team, by phone or WhatsApp. */
    case kiraCare = "kira_care"
    /** PSC 119: emergency services in every regency and city. */
    case psc119
    /** OJK 157: the financial services authority's contact centre. */
    case ojk157
    /** Satgas PASTI: the task force against illegal lenders. */
    case satgasPasti = "satgas_pasti"
    /** IASC: the anti-scam centre. */
    case iasc
    /** LAPS SJK: free mediation for financial disputes. */
    case lapsSjk = "laps_sjk"
}

/**
 One verified contact: a number to call (with an extension to dial after it), a WhatsApp number
 and a website where it has them. Kira only opens these as links the person taps; it never calls
 or sends on its own.
 */
package struct CareContact: Hashable, Sendable {
    /** Which contact. */
    package let key: CareContactKey
    /** Its name. */
    package let name: String
    /** The number to call, as dialled ("119", "157"); nil for the contacts reached on the web only. */
    package let phone: String?
    /** The extension dialled after the call connects ("8"), if any. */
    package let phoneExtension: String?
    /** The WhatsApp number as written locally ("081157157157"), if any. */
    package let whatsApp: String?
    /** Its website, if any. */
    package let website: URL?

    /** A contact. */
    package init(
        key: CareContactKey, name: String, phone: String? = nil, phoneExtension: String? = nil, whatsApp: String? = nil,
        website: URL? = nil
    ) {
        self.key = key
        self.name = name
        self.phone = phone
        self.phoneExtension = phoneExtension
        self.whatsApp = whatsApp
        self.website = website
    }
}

/** The verified contacts and the day the team last checked them. */
package struct CareContactList: Hashable, Sendable {
    /** The day the numbers were last verified. */
    package let verifiedOn: CalendarDay
    /** The contacts, in the server's order. */
    package let contacts: [CareContact]

    /** A list. */
    package init(verifiedOn: CalendarDay, contacts: [CareContact]) {
        self.verifiedOn = verifiedOn
        self.contacts = contacts
    }

    /** The contact of `key`, or nil when the list lacks it. */
    package func contact(_ key: CareContactKey) -> CareContact? {
        contacts.first { $0.key == key }
    }

    /**
     The contact of `key`, taken from the shipped list when this one lacks it, so a screen always
     has a number to show for the contacts the app ships.
     */
    package func contactOrShipped(_ key: CareContactKey) -> CareContact? {
        contact(key) ?? Self.shipped.contact(key)
    }
}
