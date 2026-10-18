import Foundation

/** One company on OJK's list of licensed fintech lenders (Cek Legalitas, REN-09). */
package struct LicensedLender: Hashable, Sendable {
    /** "PT Kredit Pintar Indonesia". */
    /** "PT Kredit Pintar Indonesia". */
    package let company: String
    /** The app or platform name people know ("Kredit Pintar"). */
    package let app: String
    /** Surat Tanda Berizin ("KEP-83/D.05/2019"). */
    package let license: String
    /** The day OJK licensed it. */
    package let licensedOn: CalendarDay
    /** Jenis Usaha: Syariah, else Konvensional. */
    package let isSharia: Bool
    /** Its website as OJK lists it; nil when unreadable. */
    package let website: URL?

    /** A lender with the given parts. */
    package init(
        company: String, app: String, license: String, licensedOn: CalendarDay, isSharia: Bool, website: URL?
    ) {
        self.company = company
        self.app = app
        self.license = license
        self.licensedOn = licensedOn
        self.isSharia = isSharia
        self.website = website
    }
}

/** What a search answered: the matches, and the list it searched (its date and size). */
package struct LegalitySearch: Hashable, Sendable {
    /** The matches, at most ten. */
    package let results: [LicensedLender]
    /** The last day OJK's list covers. */
    package let asOf: CalendarDay
    /** How many licensed lenders the list holds. */
    package let listed: Int

    /** A search answer with the given parts. */
    package init(results: [LicensedLender], asOf: CalendarDay, listed: Int) {
        self.results = results
        self.asOf = asOf
        self.listed = listed
    }
}
