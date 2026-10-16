import Foundation

/**
 A check-in the person asked for after a heavy moment (PED-05): Kira greets them in the Catat chat
 the first time they open it after `dueAt` (PED-06). There is no notification.
 */
package struct CheckIn: Hashable, Sendable {
    /** The check-in's id. */
    package let id: String
    /** From when the greeting may show. */
    package let dueAt: Date

    /** A check-in due at `dueAt`. */
    package init(id: String, dueAt: Date) {
        self.id = id
        self.dueAt = dueAt
    }
}

/** When Kira greets again (CheckIn board): Besok, Lusa or Tiga Hari Lagi. */
package enum CheckInDelay: Int, CaseIterable, Sendable {
    /** Besok, in 24 hours: the default. */
    case tomorrow = 24
    /** Lusa, in 48 hours. */
    case dayAfterTomorrow = 48
    /** Tiga Hari Lagi, in 72 hours. */
    case threeDays = 72

    /** The hours `POST /care/check-ins` takes as `afterHours`. */
    package var hours: Int { rawValue }
}
