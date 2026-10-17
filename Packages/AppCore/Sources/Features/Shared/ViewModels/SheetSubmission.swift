import APIClient

/**
 A sheet whose main action goes to the server (`docs/design-system.md`, Sheets): whether it is
 open, and the problem of a submit the server refused or never answered. A failed submit closes
 the sheet and the problem shows in a failure dialog; Coba Lagi opens the sheet again on what was
 typed, which the screen model keeps, and submits again. A check the app makes itself (an email's
 shape, a required field) stays inline in the open sheet and never comes here.
 */
package struct SheetSubmission: Equatable, Sendable {
    /** Whether the sheet is open; false when the person closes it. */
    package var isOpen: Bool
    /** The problem of the last failed submit, for the failure dialog; nil once it is closed. */
    package private(set) var failure: AppProblem?

    /** A sheet, closed unless `isOpen`. */
    package init(isOpen: Bool = false) {
        self.isOpen = isOpen
    }

    /** Opens the sheet, and again on Coba Lagi: any failure is over. */
    package mutating func open() {
        failure = nil
        isOpen = true
    }

    /** The submit went through, or the sheet was dismissed: it closes. */
    package mutating func close() {
        isOpen = false
    }

    /** The submit failed with `error`: the sheet closes and its problem waits for the dialog. */
    package mutating func fail(_ error: any Error) {
        isOpen = false
        failure = AppProblem(error)
    }

    /** Tutup, or Coba Lagi, on the failure dialog. */
    package mutating func dismissFailure() {
        failure = nil
    }
}
