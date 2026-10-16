import APIClient
import Domain
import Observation

/**
 Hapus Akun dan Data (AKN-05, 05b, 05c): Unduh Datamu Dulu emails the CSV; Hapus Permanen turns on
 once "HAPUS" is typed (any case) and deletes the account. Success clears the device and ends at
 the Splash; a failure keeps what was typed and offers Coba Lagi.
 */
@MainActor
@Observable
package final class DeleteAccountModel {
    /** The confirmation field. */
    package var confirmation = ""
    /** Where Unduh Datamu Dulu stands. */
    package private(set) var emailExport = EmailExportState.idle
    /** Hapus Permanen is waiting for the API. */
    package private(set) var isDeleting = false
    /** How the deletion went: the success or the failure dialog. */
    package var outcome: DeletionOutcome?
    private let service: any AccountService
    private let settings: any SecuritySettings
    private let onDeleted: @MainActor () -> Void

    /** A model that calls `onDeleted` once the person taps Selesai. */
    package init(
        service: any AccountService, settings: any SecuritySettings, onDeleted: @escaping @MainActor () -> Void
    ) {
        self.service = service
        self.settings = settings
        self.onDeleted = onDeleted
    }

    /** Hapus Permanen is on. */
    package var canDelete: Bool { DeletionConfirmation.accepts(confirmation) && !isDeleting }

    /** Unduh Datamu Dulu: emails the CSV to the account's address. */
    package func emailData() async {
        emailExport = .sending
        do {
            try await service.emailExport()
            emailExport = .sent
        } catch {
            emailExport = .failed(accountProblem(error))
        }
    }

    /** Hapus Permanen, and Coba Lagi after a failure. */
    package func delete() async {
        guard canDelete else { return }
        isDeleting = true
        outcome = nil
        do {
            try await service.deleteAccount(confirmation: confirmation)
            await settings.clearLocalData()
            outcome = .deleted
        } catch {
            outcome = .failed(accountProblem(error))
        }
        isDeleting = false
    }

    /** Selesai on the success dialog: back to the Splash, signed out. */
    package func finish() {
        onDeleted()
    }
}

/** Where Unduh Datamu Dulu stands. */
package enum EmailExportState: Equatable, Sendable {
    /** Not asked yet. */
    case idle
    /** Waiting for the API. */
    case sending
    /** The email is on its way. */
    case sent
    /** The API refused or could not be reached. */
    case failed(AppProblem)
}

/** How Hapus Permanen ended. */
package enum DeletionOutcome: Equatable, Sendable {
    /** The account is gone. */
    case deleted
    /** The API refused or could not be reached. */
    case failed(AppProblem)
}
