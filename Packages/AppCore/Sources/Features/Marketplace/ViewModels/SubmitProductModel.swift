import Observation

/**
 Kirim Produk ke Etalase (KOM-08): "Kirim Lewat Email" opens the mail app on a message to the Kira
 team. When no app takes the `mailto:` link, the screen says where to write instead.
 */
@MainActor
@Observable
package final class SubmitProductModel {
    /** Ready to send, or told that no mail app opened. */
    package enum Phase: Equatable, Sendable {
        /** The screen as the board draws it. */
        case ready
        /** No app opened the link: the dialog names the address to write to. */
        case mailAppMissing
    }

    /** Ready, or the dialog about the mail app. */
    package private(set) var phase = Phase.ready

    /** A model on the ready screen. */
    package init() {}

    /** What the system answered to the `mailto:` link: whether an app took it. */
    package func mailOpened(_ accepted: Bool) {
        phase = accepted ? .ready : .mailAppMissing
    }

    /** The dialog is closed. */
    package func dismiss() {
        phase = .ready
    }
}
