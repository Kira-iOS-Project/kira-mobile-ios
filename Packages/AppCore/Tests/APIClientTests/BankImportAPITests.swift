/** The bank-import calls through a canned transport: what they send, read and throw. */
import Domain
import Foundation
import Testing

@testable import APIClient

private let rowJSON =
    #"{"id":"r-1","date":"2026-10-02","description":"GRAB*TRIP","amount":18000,"type":"expense","#
    + #""category":"transport","isDuplicate":true}"#

@Suite("BankImportAPI")
struct BankImportAPITests {
    @Test("sends the parsed rows and reads the rows to review")
    func createsImport() async throws {
        let json = #"{"id":"i-1","rowCount":1,"dateFrom":"2026-10-02","dateTo":"2026-10-02","rows":[\#(rowJSON)]}"#
        let (api, transport) = KiraAPI.canned(status: 201, json: json)
        let rows = [
            BankImportUploadRowDTO(date: "2026-10-02", description: "GRAB*TRIP", amount: -18_000, category: .transport)
        ]

        let review = try await api.createBankImport(fileName: "mutasi.csv", fileSize: 2048, rows: rows)

        #expect(review.id == "i-1")
        #expect(review.dateFrom == "2026-10-02")
        #expect(review.rows.first?.isDuplicate == true)
        #expect(review.rows.first?.type == .expense)
        let body = try decodeSent(Components.Schemas.BankImportInput.self, from: try #require(await transport.request))
        #expect(body.rows.first?.amount == -18_000)
        #expect(body.fileName == "mutasi.csv")
    }

    @Test("sends the chosen rows and reads the counts")
    func commitsImport() async throws {
        let (api, transport) = KiraAPI.canned(json: #"{"savedCount":3,"skippedCount":1}"#)

        let result = try await api.commitBankImport(id: "i-1", rows: [.init(id: "r-1", category: .otherIncome)])

        #expect(result == BankImportResultDTO(savedCount: 3, skippedCount: 1))
        let sent = try #require(await transport.request)
        #expect(sent.path.hasSuffix("imports/i-1/commit"))
        #expect(
            try decodeSent(Components.Schemas.BankImportCommit.self, from: sent).rows.first?.category == .otherIncome)
    }

    @Test("throws the problem of a failure", arguments: Self.failures)
    func throwsProblems(failure: FailureCase) async {
        let (api, _) = KiraAPI.canned(status: failure.status, json: problemJSON("X_CODE"))
        await #expect(throws: failure.expectedProblem) {
            try await failure.call(api)
        }
    }

    static let failures: [FailureCase] =
        failureCases("createBankImport", statuses: [400, 401, 403, 422]) {
            _ = try await $0.createBankImport(fileName: "f", fileSize: 1, rows: [])
        }
        + failureCases("commitBankImport", statuses: [400, 401, 404, 422]) {
            _ = try await $0.commitBankImport(id: "i", rows: [])
        }
}
