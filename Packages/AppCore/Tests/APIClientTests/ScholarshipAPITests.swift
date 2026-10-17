/** The Beasiswa Kira calls: status, applying and withdrawing. */
import Foundation
import HTTPTypes
import Testing

@testable import APIClient

private let applicationJSON = #"""
    {"id":"a-1","status":"accepted","situations":["income_stopped","medical_costs"],"story":"Baru kena PHK.",\#
    "submittedAt":"2026-10-16T05:00:00.000Z","decideBy":"2026-10-21","decidedAt":"2026-10-17T05:00:00.000Z",\#
    "grantStart":"2026-10-17","grantEnd":"2027-01-16","extensionFrom":"2027-01-02"}
    """#

private struct ApplicationBody: Decodable { let situations: [String], story: String? }

@Suite("ScholarshipAPI")
struct ScholarshipAPITests {
    @Test("reads the places and the latest application")
    func readsStatus() async throws {
        let json =
            #"{"eligible":false,"ineligibleReason":"has_scholarship","quota":{"remaining":1,"total":4},"#
            + #""application":\#(applicationJSON)}"#
        let status = try await KiraAPI.canned(json: json).api.getScholarship()
        #expect(status.remainingPlaces == 1 && status.totalPlaces == 4)
        let application = try #require(status.application)
        #expect(application.status == .accepted && application.situations == [.incomeStopped, .medicalCosts])
        #expect(application.decideBy == "2026-10-21")
        #expect(application.decidedAt == Date(timeIntervalSince1970: 1_792_213_200))
        #expect(application.submittedAt == Date(timeIntervalSince1970: 1_792_126_800))
        #expect(application.grantStart == "2026-10-17" && application.grantEnd == "2027-01-16")
        #expect(application.extensionFrom == "2027-01-02")
    }

    @Test("reads a person with no application")
    func readsEligible() async throws {
        let json = #"{"eligible":true,"ineligibleReason":null,"quota":{"remaining":0,"total":0},"application":null}"#
        let status = try await KiraAPI.canned(json: json).api.getScholarship()
        #expect(status.application == nil && status.totalPlaces == 0)
    }

    @Test("applies with situations and a story, and withdraws")
    func appliesAndWithdraws() async throws {
        let (api, transport) = KiraAPI.canned(status: 201, json: applicationJSON)
        let application = try await api.applyForScholarship(situations: [.chasedByLender], story: nil)
        #expect(application.status == .accepted)
        let body = try #require(await transport.request).decoded(ApplicationBody.self)
        #expect(body.situations == ["chased_by_lender"] && body.story == nil)
        let (withdrawer, withdrawn) = KiraAPI.canned(status: 204)
        try await withdrawer.withdrawScholarshipApplication()
        #expect(try #require(await withdrawn.request).method == .delete)
    }

    @Test("throws every problem the scholarship routes answer")
    func problems() async {
        await expectProblems([401]) { _ = try await $0.getScholarship() }
        await expectProblems([401, 409, 422]) {
            _ = try await $0.applyForScholarship(situations: [.otherHardship], story: "x")
        }
        await expectProblems([401, 404]) { try await $0.withdrawScholarshipApplication() }
    }
}
