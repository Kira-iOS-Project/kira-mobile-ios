import Foundation

/** A Beasiswa Kira application (`Application` in the API). */
package struct ScholarshipApplication: Hashable, Sendable {
    /** Where the application stands: the backend's `APPLICATION_STATUS` values. */
    package enum Status: String, CaseIterable, Codable, Sendable {
        /** Sedang Ditinjau. */
        case inReview = "in_review"
        /** Sent while the month's quota was used up: on the waiting list. */
        case waitlisted
        /** Kira Plus granted. */
        case accepted
        /** Taken back by the person (Tarik Pengajuan). */
        case withdrawn
    }

    /** Where it stands. */
    package let status: Status
    /** What the person is facing, at least one. */
    package let situations: [ScholarshipSituation]
    /** When it was sent. */
    package let submittedAt: Date
    /** The last day the review takes (three working days). */
    package let decideBy: CalendarDay
    /** The day it was accepted, once it is. */
    package let decidedAt: CalendarDay?
    /** The grant's first and last day, once accepted. */
    package let grant: ClosedRange<CalendarDay>?
    /** The first day an extension can be asked for (14 days before the grant ends). */
    package let extensionFrom: CalendarDay?

    /** The application as the API sends it. */
    package init(
        status: Status, situations: [ScholarshipSituation], submittedAt: Date, decideBy: CalendarDay,
        decision: Decision? = nil
    ) {
        self.status = status
        self.situations = situations
        self.submittedAt = submittedAt
        self.decideBy = decideBy
        decidedAt = decision?.decidedAt
        grant = decision.map { $0.grantStart...$0.grantEnd }
        extensionFrom = decision?.extensionFrom
    }

    /** The decision's days, present once an application is accepted. */
    package struct Decision: Hashable, Sendable {
        /** The day it was accepted. */
        package let decidedAt: CalendarDay
        /** The grant's first day. */
        package let grantStart: CalendarDay
        /** The grant's last day. */
        package let grantEnd: CalendarDay
        /** The first day an extension can be asked for. */
        package let extensionFrom: CalendarDay

        /** The decision as the API sends it. */
        package init(
            decidedAt: CalendarDay, grantStart: CalendarDay, grantEnd: CalendarDay, extensionFrom: CalendarDay
        ) {
            self.decidedAt = decidedAt
            self.grantStart = grantStart
            self.grantEnd = grantEnd
            self.extensionFrom = extensionFrom
        }
    }
}
