import APIClient
import Domain
import Observation

/**
 Hapus Akun dan Data (AKN-05, 05b, 05c), a sheet over Data & Privasi: Unduh Datamu Dulu emails the
 CSV; Hapus Permanen turns on once "HAPUS" is typed (any case) and deletes the account. Success
 clears the device and ends at the Splash. A failure of either closes the sheet for its dialog and
 keeps what was typed; Coba Lagi opens the sheet again and repeats the action that failed.
 */
@MainActor
@Observable
package final class DeleteAccountModel {
    /** What the sheet sends. */
    package enum Action: Equatable, Sendable {
        /** Unduh Datamu Dulu. */
        case emailData
        /** Hapus Permanen. */
        case delete
    }

    /** The sheet, and the failure of its last action. */
    package var sheet = SheetSubmission()
    /** The confirmation field. */
    package var confirmation = ""
    /** Where Unduh Datamu Dulu stands. */
    package private(set) var emailExport = EmailExportState.idle
    /** Hapus Permanen is waiting for the API. */
    package private(set) var isDeleting = false
    /** The success dialog is up. */
    package var showsDeleted = false
    /** The action that ran last, which Coba Lagi repeats. */
    package private(set) var lastAction = Action.delete
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

    /** "Hapus Akun dan Data" on Data & Privasi: opens the sheet. */
    package func open() {
        sheet.open()
    }

    /** Unduh Datamu Dulu: emails the CSV to the account's address, once at a time. */
    package func emailData() async {
        guard emailExport != .sending else { return }
        lastAction = .emailData
        emailExport = .sending
        do {
            try await service.emailExport()
            emailExport = .sent
        } catch {
            emailExport = .idle
            sheet.fail(error)
        }
    }

    /** Hapus Permanen. */
    package func delete() async {
        guard canDelete else { return }
        lastAction = .delete
        isDeleting = true
        do {
            try await service.deleteAccount(confirmation: confirmation)
            await settings.clearLocalData()
            showsDeleted = true
        } catch {
            sheet.fail(error)
        }
        isDeleting = false
    }

    /** Coba Lagi on the failure dialog: the sheet opens again and the failed action runs again. */
    package func retry() async {
        sheet.open()
        switch lastAction {
        case .emailData: await emailData()
        case .delete: await delete()
        }
    }

    /** Selesai on the success dialog: back to the Splash, signed out. */
    package func finish() {
        onDeleted()
    }
}

/** Where Unduh Datamu Dulu stands; a failure goes to the sheet's dialog. */
package enum EmailExportState: Equatable, Sendable {
    /** Not asked yet, or asked and failed. */
    case idle
    /** Waiting for the API. */
    case sending
    /** The email is on its way. */
    case sent
}
