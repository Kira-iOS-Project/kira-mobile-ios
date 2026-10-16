import APIClient
import Domain
import Foundation
import Observation

/**
 Mode Darurat Utang (PED-07): the situations, OJK's official contacts and Beasiswa Kira. Opening
 the screen turns the mode on (`PUT /care/debt-emergency`), which makes the account eligible for
 Beasiswa Kira. The screen never shows that call's failure: it tries again quietly a few times
 while the screen stays open, and again the next time it opens; only the Beasiswa Kira card waits
 for one try before opening it. The contacts come from
 `GET /care/contacts` through CareContactsModel: the shipped list at once, the server's when it
 arrives.
 */
@MainActor
@Observable
package final class DebtEmergencyModel {
    /** Loading, then the contacts: the server's, or the shipped ones. */
    package private(set) var phase: ScreenPhase<CareContactList> = .loading

    @ObservationIgnored private let contacts: CareContactsModel
    @ObservationIgnored private let service: any DebtEmergencyService
    @ObservationIgnored private let retryDelays: [Duration]
    @ObservationIgnored private let sleep: @Sendable (Duration) async throws -> Void
    @ObservationIgnored private var isActive = false

    /**
     The screen. After a failed activation it waits each of `retryDelays` in turn and tries again;
     `sleep` waits, and throws once the screen is gone.
     */
    package init(
        care: any CareService, service: any DebtEmergencyService,
        retryDelays: [Duration] = [.seconds(5), .seconds(30), .seconds(120)],
        sleep: @escaping @Sendable (Duration) async throws -> Void = { try await Task.sleep(for: $0) }
    ) {
        contacts = CareContactsModel(service: care)
        self.service = service
        self.retryDelays = retryDelays
        self.sleep = sleep
    }

    /** Loads the contacts; a failure falls back to the shipped list, so the screen always shows. */
    package func load() async {
        await contacts.load()
        phase = .loaded(contacts.contacts)
    }

    /** Turns the mode on, once per screen; a failure is retried quietly, never shown. */
    package func activate() async {
        guard !isActive else { return }
        if await attempt() { return }
        for delay in retryDelays {
            do { try await sleep(delay) } catch { return }
            if await attempt() { return }
        }
    }

    /**
     Makes sure the mode is on before Beasiswa Kira opens, whose application the server refuses
     until it is: one more try, awaited, unless an earlier one landed. Its failure stays quiet too;
     the quiet retries of `activate()` carry on.
     */
    package func ensureActive() async {
        guard !isActive else { return }
        _ = await attempt()
    }

    /** The `tel:` link of a contact. */
    package func callURL(_ key: CareContactKey) -> URL? {
        contact(key)?.callURL
    }

    /** A contact's website, opened in the browser. */
    package func website(_ key: CareContactKey) -> URL? {
        contact(key)?.website
    }

    /** A contact's website as the row shows it: the host alone ("sipasti.ojk.go.id"). */
    package func siteName(_ key: CareContactKey) -> String? {
        website(key)?.host()
    }

    /** A contact: the server's, or the shipped one until it arrives or when the server lacks it. */
    package func contact(_ key: CareContactKey) -> CareContact? {
        contacts.contact(key)
    }

    private func attempt() async -> Bool {
        do {
            try await service.activate()
            isActive = true
        } catch {
            isActive = false
        }
        return isActive
    }
}
