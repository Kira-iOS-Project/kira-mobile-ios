/**
 Rule 24 for AKN: Profil and its screens, the plans, the subscription and Beasiswa Kira.
 Each screen opens through `-KiraScreen <name>` and is audited top to bottom (ScreenAudit.swift).
 */
import XCTest

nonisolated final class AccountAuditTests: XCTestCase {
    @MainActor
    func testProfilePassesTheAudit() throws {
        try auditScreen("profile")
    }

    @MainActor
    func testSecurityPassesTheAudit() throws {
        try auditScreen("security")
    }

    @MainActor
    func testPrivacyPassesTheAudit() throws {
        try auditScreen("privacy")
    }

    @MainActor
    func testAboutPassesTheAudit() throws {
        try auditScreen("about")
    }

    @MainActor
    func testTermsPassesTheAudit() throws {
        try auditScreen("terms")
    }

    @MainActor
    func testPrivacyPolicyPassesTheAudit() throws {
        try auditScreen("privacyPolicy")
    }

    @MainActor
    func testComplaintsPassesTheAudit() throws {
        try auditScreen("complaints")
    }

    @MainActor
    func testPlansPassesTheAudit() throws {
        try auditScreen("plans")
    }

    @MainActor
    func testPlansYearlyPassesTheAudit() throws {
        try auditScreen("plansYearly")
    }

    @MainActor
    func testPlanDetailPassesTheAudit() throws {
        try auditScreen("planDetail")
    }

    @MainActor
    func testCheckoutPassesTheAudit() throws {
        try auditScreen("checkout")
    }

    @MainActor
    func testSubscriptionPassesTheAudit() throws {
        try auditScreen(
            "subscription",
            accepting: { issue in
                /**
                 Accepted: the hero's renewal and reminder dates, on-hero-muted over the hero hills in
                 the board's colours (KelolaLangganan.dc.html); the owner keeps the design, as for
                 "Lupa PIN?" on the lock screen. Every other finding fails.
                 */
                guard issue.auditType == .contrast, let label = issue.element?.label else { return false }
                return label.hasPrefix("Diperpanjang ") || label.hasPrefix("Email pengingat ")
            })
    }

    @MainActor
    func testInvoicesPassesTheAudit() throws {
        try auditScreen("invoices")
    }

    @MainActor
    func testTreatPassesTheAudit() throws {
        try auditScreen("treat")
    }

    @MainActor
    func testScholarshipPassesTheAudit() throws {
        try auditScreen("scholarship")
    }

    @MainActor
    func testScholarshipApplyPassesTheAudit() throws {
        try auditScreen("scholarshipApply")
    }

    @MainActor
    func testScholarshipPendingPassesTheAudit() throws {
        try auditScreen("scholarshipPending")
    }

    @MainActor
    func testScholarshipAcceptedPassesTheAudit() throws {
        try auditScreen("scholarshipAccepted")
    }
}
