/**
 Rule 24 for CAT: Riwayat, Detail Transaksi, Riwayat Percakapan, Impor Mutasi and Tinjau Hasil Impor (the chat screens join with Catat).
 Each screen opens through `-KiraScreen <name>` and is audited top to bottom (ScreenAudit.swift).
 */
import XCTest

nonisolated final class RecordAuditTests: XCTestCase {
    @MainActor
    func testHistoryPassesTheAudit() throws {
        try auditScreen("history")
    }

    @MainActor
    func testTransactionPassesTheAudit() throws {
        try auditScreen("transaction")
    }

    @MainActor
    func testConversationPassesTheAudit() throws {
        try auditScreen("conversation")
    }

    @MainActor
    func testStatementImportPassesTheAudit() throws {
        try auditScreen("statementImport")
    }

    @MainActor
    func testImportReviewPassesTheAudit() throws {
        try auditScreen("importReview")
    }
}
