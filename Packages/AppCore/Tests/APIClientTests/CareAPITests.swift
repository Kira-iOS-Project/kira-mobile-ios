/** GET /care/contacts through a canned transport. */
import Domain
import Foundation
import HTTPTypes
import Testing

@testable import APIClient

@Suite("CareAPI")
struct CareAPITests {
    @Test("reads the verified contacts into the Domain's list, web-only ones without a phone")
    func readsContacts() async throws {
        let (api, transport) = KiraAPI.canned(json: careContactsJSON)

        let list = try await api.listCareContacts()

        #expect(list.verifiedOn == CalendarDay(year: 2026, month: 10, day: 1))
        #expect(list.contacts.map(\.key) == [.healing119, .ojk157, .satgasPasti])
        #expect(list.contact(.healing119)?.callURL?.absoluteString == "tel:119,8")
        #expect(list.contact(.healing119)?.website?.absoluteString == "https://healing119.id")
        #expect(list.contact(.ojk157)?.whatsApp == "081157157157")
        #expect(list.contact(.satgasPasti)?.phone == nil)
        let sent = try #require(await transport.request)
        #expect(sent.method == .get)
        #expect(sent.path.hasSuffix("care/contacts"))
    }

    @Test("a day it cannot read is a problem without a code")
    func badDay() async {
        let (api, _) = KiraAPI.canned(json: #"{"verifiedOn":"1 Oktober","contacts":[]}"#)
        await #expect(throws: AppProblem()) { try await api.listCareContacts() }
    }

    @Test(
        "throws the problem of a failure",
        arguments: failureCases("listCareContacts", statuses: [401]) { _ = try await $0.listCareContacts() })
    func throwsProblems(failure: FailureCase) async {
        let (api, _) = KiraAPI.canned(status: failure.status, json: problemJSON("X_CODE"))
        await #expect(throws: failure.expectedProblem(documented: failure.status != 500)) {
            try await failure.call(api)
        }
    }
}

private let careContactsJSON = """
    {"verifiedOn":"2026-10-01","contacts":[
    {"key":"healing119","name":"Healing119","phone":"119","extension":"8","whatsapp":null,
     "url":"https://healing119.id","note":"Free mental-health counselling by health workers."},
    {"key":"ojk157","name":"OJK 157","phone":"157","extension":null,"whatsapp":"081157157157","url":null,
     "note":"The financial services authority."},
    {"key":"satgas_pasti","name":"Satgas PASTI","phone":null,"extension":null,"whatsapp":null,
     "url":"https://sipasti.ojk.go.id","note":"Reports of illegal lending and investment."}]}
    """
