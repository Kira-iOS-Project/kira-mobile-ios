import APIClient

/**
 What the Komunitas screens do with an API problem, decided once over every `ProblemCode` and nil
 (AGENTS.md Rule 12), so a new code fails the build here until it is placed.
 */
package enum CommunityProblemKind: Equatable, Sendable {
    /** The group is gone or suspended: Detail Grup shows it in place of the group. */
    case groupGone
    /** The group's link is still being checked: try again later, not now. */
    case linkUnavailable
    /** The rules in force are not accepted yet: Aturan Komunitas opens again. */
    case rulesNotAccepted
    /** A report on this group is already open. */
    case reportDuplicate
    /** The API refused what was sent (an old rules version, a story): sending it again cannot help. */
    case refused
    /** Anything else: its own message, or the generic one with the reference. */
    case other

    /** The kind of `code`; nil is a code this build does not know. */
    package init(_ code: ProblemCode?) {
        switch code {
        case .communityGroupNotFound: self = .groupGone
        case .communityLinkUnavailable: self = .linkUnavailable
        case .communityRulesNotAccepted: self = .rulesNotAccepted
        case .communityReportDuplicate: self = .reportDuplicate
        case .validationFailed: self = .refused
        case nil, .routeNotFound, .requestTooLarge, .requestTimeout, .httpError, .internalError,
            .metaHealthUnhealthy, .authCodeRateLimited, .authVerifyRateLimited, .authCodeInvalid, .authCodeExpired,
            .authCodeAttemptsExceeded, .authUnauthenticated, .authRefreshInvalid, .emailDeliveryFailed,
            .accountExportRateLimited, .scoreNotAvailable, .chatAIDisabled, .chatMessageNotFound,
            .chatDraftsNotPending, .planFeatureUnavailable, .receiptTotalMismatch, .transactionNotFound,
            .transactionBatchNotFound, .transactionUndoExpired, .importNotFound, .importRangeTooLong,
            .importRowUnknown, .subscriptionNotFound, .subscriptionNotCancellable, .subscriptionNotPaid,
            .scholarshipNotEligible, .scholarshipApplicationNotFound, .scholarshipDebtEmergencyRequired,
            .communityProductNotFound:
            self = .other
        }
    }

    /** Whether sending the same thing again can work. */
    package var allowsRetry: Bool {
        switch self {
        case .groupGone, .linkUnavailable, .reportDuplicate, .refused: false
        case .rulesNotAccepted, .other: true
        }
    }
}

extension CommunityFailure {
    /** The problem's kind; nil when there was no answer. */
    package var kind: CommunityProblemKind? {
        guard case .problem(let problem) = self else { return nil }
        return CommunityProblemKind(problem.knownCode)
    }
}
