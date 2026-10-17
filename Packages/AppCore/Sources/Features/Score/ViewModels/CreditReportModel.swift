import Foundation
import Observation

/**
 Cek SLIK (SKR-06): the content team's four steps to one's own credit record at iDebKu OJK, free.
 Kira never asks for, stores or reads SLIK data: the screen's only way out is OJK's own site, which
 opens in the system browser. The steps are static words from the String Catalog, so the screen has
 nothing to load and sits in `loaded` from the start, with the site as its value; `empty` is the one
 other phase it can take, when no site could be built, and then the screen keeps its guide without
 the button. It never loads or fails.
 */
@MainActor
@Observable
package final class CreditReportModel {
    /** The guide with iDebKu's address, or `empty` without one. */
    package private(set) var phase: ScreenPhase<URL>
    /** iDebKu while the system browser shows it over the screen, else nil. */
    package private(set) var presentedSite: URL?

    /** The guide on `site`, iDebKu OJK by default. */
    package init(site: URL? = URL(string: "https://idebku.ojk.go.id")) {
        phase = site.map { .loaded($0) } ?? .empty
    }

    /** Buka iDebKu OJK: the browser opens on the site, when there is one. */
    package func openSite() {
        presentedSite = phase.value
    }

    /** The browser was closed: back to the guide. */
    package func closeSite() {
        presentedSite = nil
    }
}
