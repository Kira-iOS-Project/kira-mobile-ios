import APIClient

extension ProductModel {
    /**
     Whether a failed load means the product left Etalase for good, so the screen offers the way
     back instead of Coba Lagi. Every code is listed: a new one fails the build until it is placed.
     */
    static func isGone(_ code: ProblemCode?) -> Bool {
        switch code {
        case .communityProductNotFound:
            true
        case nil, .validationFailed, .routeNotFound, .requestTooLarge, .requestTimeout, .httpError,
            .internalError, .metaHealthUnhealthy, .authCodeRateLimited, .authVerifyRateLimited, .authCodeInvalid,
            .authCodeExpired, .authCodeAttemptsExceeded, .authUnauthenticated, .authRefreshInvalid,
            .emailDeliveryFailed, .accountExportRateLimited, .scoreNotAvailable, .chatAIDisabled,
            .chatMessageNotFound, .chatDraftsNotPending, .planFeatureUnavailable, .receiptTotalMismatch,
            .transactionNotFound, .transactionBatchNotFound, .transactionUndoExpired, .importNotFound,
            .importRangeTooLong, .importRowUnknown, .subscriptionNotFound, .subscriptionNotCancellable,
            .subscriptionNotPaid, .scholarshipNotEligible, .scholarshipApplicationNotFound,
            .scholarshipDebtEmergencyRequired, .communityGroupNotFound, .communityLinkUnavailable,
            .communityReportDuplicate, .communityRulesNotAccepted, .careCheckInNotFound, .careSafetyPlanNotFound,
            .payoffExtraTooHigh, .payoffNothingToPlan, .payoffPlanNotFound, .payoffDebtNotFound, .payoffPaymentTooHigh,
            .payoffPaymentAlreadyRecorded, .assetNotFound, .goalNotFound,
            .goalEmergencyExists, .goalDepositConflict:
            false
        }
    }
}
