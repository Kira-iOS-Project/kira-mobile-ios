/** `GET /scholarship`: the month's quota and the person's application. */
package struct ScholarshipOverview: Hashable, Sendable {
    /** What the screen shows: the explanation, or the application's status. */
    package enum Stage: Hashable, Sendable {
        /** Beasiswa Kira explained, with Ajukan Beasiswa (AKN-09). */
        case intro
        /** Sent and waiting: in review or on the waiting list (AKN-10c). */
        case pending(ScholarshipApplication)
        /** Accepted: Kira Plus is on (AKN-10d). */
        case accepted(ScholarshipApplication)
    }

    /** Scholarships left this month. */
    package let quotaRemaining: Int
    /** Scholarships this month's Traktir Kira paid for. */
    package let quotaTotal: Int
    /** The latest application, if any. */
    package let application: ScholarshipApplication?

    /** The overview as the API sends it. */
    package init(quotaRemaining: Int, quotaTotal: Int, application: ScholarshipApplication?) {
        self.quotaRemaining = quotaRemaining
        self.quotaTotal = quotaTotal
        self.application = application
    }

    /** The stage the application puts the screen in; a withdrawn one shows the explanation again. */
    package var stage: Stage {
        guard let application else { return .intro }
        switch application.status {
        case .inReview, .waitlisted: return .pending(application)
        case .accepted: return .accepted(application)
        case .withdrawn: return .intro
        }
    }
}
