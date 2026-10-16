import Foundation

/** Beasiswa Kira (AKN-10 to AKN-10d): three months of Kira Plus, funded by gifted months. */

/** What the applicant is going through. */
package enum ScholarshipSituationDTO: String, CaseIterable, Sendable {
    /** Cicilan menumpuk. */
    case instalmentsPilingUp = "instalments_piling_up"
    /** Dikejar penagih. */
    case chasedByLender = "chased_by_lender"
    /** Penghasilan berhenti. */
    case incomeStopped = "income_stopped"
    /** Biaya berobat. */
    case medicalCosts = "medical_costs"
    /** Lainnya. */
    case otherHardship = "other_hardship"
}

/** Why a person cannot apply now. */
package enum ScholarshipIneligibilityDTO: String, CaseIterable, Sendable {
    /** A bought plan is active. */
    case hasPaidPlan = "has_paid_plan"
    /** A scholarship is running. */
    case hasScholarship = "has_scholarship"
    /** An application is open. */
    case hasOpenApplication = "has_open_application"
}

/** Where an application stands. */
package enum ApplicationStatusDTO: String, CaseIterable, Sendable {
    /** Being reviewed. */
    case inReview = "in_review"
    /** No place this month; waits for the next. */
    case waitlisted
    /** Granted: three months of Kira Plus. */
    case accepted
    /** Withdrawn by the applicant. */
    case withdrawn
}

/** One application. */
package struct ScholarshipApplicationDTO: Hashable, Sendable {
    /** Its id. */
    package let id: String
    /** Where it stands. */
    package let status: ApplicationStatusDTO
    /** The situations chosen. */
    package let situations: [ScholarshipSituationDTO]
    /** The applicant's story; nil when none. */
    package let story: String?
    /** When it was sent. */
    package let submittedAt: Date
    /** The promised answer date: three working days (`YYYY-MM-DD`). */
    package let decideBy: String
    /** When it was decided. */
    package let decidedAt: Date?
    /** The grant's first day. */
    package let grantStart: String?
    /** The grant's last day. */
    package let grantEnd: String?
    /** From when an extension can be asked for: 14 days before the end. */
    package let extensionFrom: String?

    init(_ application: Components.Schemas.ScholarshipApplication) throws {
        id = application.id
        status = try bridged(application.status)
        situations = try application.situations.map { try bridged($0) }
        story = application.story
        submittedAt = application.submittedAt
        decideBy = application.decideBy
        decidedAt = application.decidedAt
        grantStart = application.grantStart
        grantEnd = application.grantEnd
        extensionFrom = application.extensionFrom
    }
}

/** Whether a person may apply, this month's places, and their latest application. */
package struct ScholarshipDTO: Hashable, Sendable {
    /** May apply now. */
    package let eligible: Bool
    /** Why not; nil when eligible. */
    package let ineligibleReason: ScholarshipIneligibilityDTO?
    /** Places left this month. */
    package let remainingPlaces: Int
    /** Places this month. */
    package let totalPlaces: Int
    /** The latest application; nil when none. */
    package let application: ScholarshipApplicationDTO?

    init(_ status: Components.Schemas.Scholarship) throws {
        eligible = status.eligible
        ineligibleReason = try bridged(status.ineligibleReason)
        remainingPlaces = status.quota.remaining
        totalPlaces = status.quota.total
        application = try status.application.map(ScholarshipApplicationDTO.init)
    }
}
