/**
 A problem detail (RFC 9457) as this app reads it. The generated client decodes every
 `Problem` response into this type (typeOverrides in openapi-generator-config.yaml), so a code
 the backend adds after this build shipped still decodes: it becomes the generic message.
 AGENTS.md Rule 12 and .claude/rules/common/error-codes.md say how screens use it.
 */

/**
 A problem detail body from the API. Each member is read on its own and a member of the wrong
 type is ignored (RFC 9457 §3.1), so a malformed field never hides the code. Only what a screen
 uses is read: `title` and `status` serve the server's logs, and `detail` never reaches a screen.
 */
package struct AppProblem: Error, Codable, Hashable, Sendable {
    /**
     The API's problem-type base. `type` is this base plus the code, and it equals
     `x-problem-type-base` in the spec (`scripts/check/error-codes.sh` compares them). Changing it
     after a release turns every error in the installed apps into the generic message.
     */
    package static let typeBase = "https://api-kira.serenitycode.tech/problems/"

    /** The problem type: `typeBase` plus the code. Absent means `about:blank`. */
    package let type: String?
    /** The registered error code, such as `ROUTE_NOT_FOUND`. */
    package let code: String?
    /** The request's id, shown in the reference of a problem this app does not know. */
    package let requestId: String?

    /** A problem with the given members, for tests and previews. */
    package init(type: String? = nil, code: String? = nil, requestId: String? = nil) {
        self.type = type
        self.code = code
        self.requestId = requestId
    }

    /** Decodes each member with `try?`, so a member with an unexpected type reads as absent. */
    package init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try? container.decode(String.self, forKey: .type)
        code = try? container.decode(String.self, forKey: .code)
        requestId = try? container.decode(String.self, forKey: .requestId)
    }

    /**
     The code this app has a message for, or nil. A known code counts only when `type` is this
     API's base plus that code, or when `type` is absent or `about:blank` (an API that does not
     mint types yet). A known code under another base, or a `type` whose tail differs from
     `code`, is unknown.
     */
    package var knownCode: ProblemCode? {
        guard let code, let known = ProblemCode(rawValue: code) else { return nil }
        switch type {
        case nil, "about:blank", Self.typeBase + code:
            return known
        default:
            return nil
        }
    }

    /**
     The String Catalog key of the message to show: `problem.<CODE>` for a known code,
     `problem.connection` when the request got no answer, else `problem.unknown`, which is shown
     together with `reference`.
     */
    package var messageKey: String {
        guard let knownCode else { return isConnectionLoss ? "problem.connection" : "problem.unknown" }
        return "problem.\(knownCode.rawValue)"
    }

    /**
     `CODE · <first 8 characters of the request id>`, the reference a person can quote to
     support. `UNKNOWN` stands in for a missing code.
     */
    package var reference: String {
        let shown = code ?? "UNKNOWN"
        guard let requestId, !requestId.isEmpty else { return shown }
        return "\(shown) · \(requestId.prefix(8))"
    }
}

/**
 Every error code this app has a message for: the `Problem.code` enum of the backend's spec,
 which `scripts/check/error-codes.sh` compares with these raw values. Screens switch over it with
 no `default:`, so a case added here fails the build until every screen maps it.
 */
package enum ProblemCode: String, CaseIterable, Sendable {
    /** The request body or a parameter failed the API's schema. */
    case validationFailed = "VALIDATION_FAILED"
    /** No route matches the request: an app older or newer than the API. */
    case routeNotFound = "ROUTE_NOT_FOUND"
    /** The request body is larger than the API accepts. */
    case requestTooLarge = "REQUEST_TOO_LARGE"
    /** The request took longer than the API's time budget. */
    case requestTimeout = "REQUEST_TIMEOUT"
    /** The API refused the request for a reason it names only by its status. */
    case httpError = "HTTP_ERROR"
    /** The server failed; the reference identifies the request. */
    case internalError = "INTERNAL_ERROR"
    /** The API is up but its database is not answering. */
    case metaHealthUnhealthy = "META_HEALTH_UNHEALTHY"
    /** Too many codes were asked for; wait before asking again. */
    case authCodeRateLimited = "AUTH_CODE_RATE_LIMITED"
    /** Too many codes were checked for this address or network; wait a few minutes. */
    case authVerifyRateLimited = "AUTH_VERIFY_RATE_LIMITED"
    /** The sign-in code does not match. */
    case authCodeInvalid = "AUTH_CODE_INVALID"
    /** The sign-in code is past its ten minutes. */
    case authCodeExpired = "AUTH_CODE_EXPIRED"
    /** Five wrong tries ended the code. */
    case authCodeAttemptsExceeded = "AUTH_CODE_ATTEMPTS_EXCEEDED"
    /** No valid session: sign in again. */
    case authUnauthenticated = "AUTH_UNAUTHENTICATED"
    /** The session can no longer be renewed: sign in again. */
    case authRefreshInvalid = "AUTH_REFRESH_INVALID"
    /** The email could not be sent right now. */
    case emailDeliveryFailed = "EMAIL_DELIVERY_FAILED"
    /** The data export was emailed less than ten minutes ago. */
    case accountExportRateLimited = "ACCOUNT_EXPORT_RATE_LIMITED"
    /** There is no Kira Score before the health check. */
    case scoreNotAvailable = "SCORE_NOT_AVAILABLE"
    /** Kira AI is off in the consents, so chat reading is off. */
    case chatAIDisabled = "CHAT_AI_DISABLED"
    /** The chat message is gone. */
    case chatMessageNotFound = "CHAT_MESSAGE_NOT_FOUND"
    /** The drafts were already saved or discarded. */
    case chatDraftsNotPending = "CHAT_DRAFTS_NOT_PENDING"
    /** The current plan does not include this feature. */
    case planFeatureUnavailable = "PLAN_FEATURE_UNAVAILABLE"
    /** The receipt's items do not add up to its total. */
    case receiptTotalMismatch = "RECEIPT_TOTAL_MISMATCH"
    /** The transaction is gone. */
    case transactionNotFound = "TRANSACTION_NOT_FOUND"
    /** The saved batch is gone. */
    case transactionBatchNotFound = "TRANSACTION_BATCH_NOT_FOUND"
    /** The 30 seconds to undo have passed. */
    case transactionUndoExpired = "TRANSACTION_UNDO_EXPIRED"
    /** The bank-statement import is gone. */
    case importNotFound = "IMPORT_NOT_FOUND"
    /** The statement covers more than three months. */
    case importRangeTooLong = "IMPORT_RANGE_TOO_LONG"
    /** A row does not belong to this import. */
    case importRowUnknown = "IMPORT_ROW_UNKNOWN"
    /** There is no paid plan. */
    case subscriptionNotFound = "SUBSCRIPTION_NOT_FOUND"
    /** A Beasiswa Kira plan cannot be cancelled. */
    case subscriptionNotCancellable = "SUBSCRIPTION_NOT_CANCELLABLE"
    /** A Beasiswa Kira plan is free: it has no payment method to change. */
    case subscriptionNotPaid = "SUBSCRIPTION_NOT_PAID"
    /** Applying is not possible right now. */
    case scholarshipNotEligible = "SCHOLARSHIP_NOT_ELIGIBLE"
    /** There is no open application. */
    case scholarshipApplicationNotFound = "SCHOLARSHIP_APPLICATION_NOT_FOUND"
    /** The community group is gone or suspended. */
    case communityGroupNotFound = "COMMUNITY_GROUP_NOT_FOUND"
    /** The marketplace product is gone. */
    case communityProductNotFound = "COMMUNITY_PRODUCT_NOT_FOUND"
    /** This person already has an open report on the group. */
    case communityReportDuplicate = "COMMUNITY_REPORT_DUPLICATE"
    /** The current community rules are not accepted yet. */
    case communityRulesNotAccepted = "COMMUNITY_RULES_NOT_ACCEPTED"
    /** The check-in is gone (cancelled, seen or never made). */
    case careCheckInNotFound = "CARE_CHECK_IN_NOT_FOUND"
    /** No Rencana Keselamatanku has been saved yet. */
    case careSafetyPlanNotFound = "CARE_SAFETY_PLAN_NOT_FOUND"
    /** Otherwise eligible, but Mode Darurat Utang has never been opened. */
    case scholarshipDebtEmergencyRequired = "SCHOLARSHIP_DEBT_EMERGENCY_REQUIRED"
    /** The community group does not exist, or the team suspended it for review. */
    case communityGroupNotFound = "COMMUNITY_GROUP_NOT_FOUND"
    /** The group has no checked invite link yet; the curation team is checking it. */
    case communityLinkUnavailable = "COMMUNITY_LINK_UNAVAILABLE"
    /** The Etalase product does not exist. */
    case communityProductNotFound = "COMMUNITY_PRODUCT_NOT_FOUND"
    /** The person already has an open report on this group. */
    case communityReportDuplicate = "COMMUNITY_REPORT_DUPLICATE"
    /** The current community rules have not been accepted yet. */
    case communityRulesNotAccepted = "COMMUNITY_RULES_NOT_ACCEPTED"
    /** The check-in is gone (cancelled, seen or never made). */
    case careCheckInNotFound = "CARE_CHECK_IN_NOT_FOUND"
    /** No Rencana Keselamatanku has been saved yet. */
    case careSafetyPlanNotFound = "CARE_SAFETY_PLAN_NOT_FOUND"
}
