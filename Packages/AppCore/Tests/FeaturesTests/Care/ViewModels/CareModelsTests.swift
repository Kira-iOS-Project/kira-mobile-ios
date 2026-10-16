import APIClient
import Domain
import Foundation
import Testing

@testable import Features

/** Answers `contacts()` with `result`. */
struct FakeCareService: CareService {
    var result: Result<CareContactList, AppProblem> = .success(CareFixtures.server)
    /** An error other than a problem, thrown instead of `result` (a lost connection). */
    var error: (any Error)?

    func contacts() throws -> CareContactList {
        if let error { throw error }
        return try result.get()
    }
}

enum CareFixtures {
    static let kiraCare = CareContact(
        key: .kiraCare, name: "Layanan Kira Peduli", phone: "081234567890", whatsApp: "081234567890")
    static let server = CareContactList(
        verifiedOn: CalendarDay(year: 2026, month: 11, day: 1),
        contacts: [kiraCare, CareContact(key: .psc119, name: "PSC 119", phone: "112")])
}

@MainActor
@Suite("CareContactsModel")
struct CareContactsModelTests {
    @Test("shows the shipped list at once, then the server's")
    func loads() async {
        let model = CareContactsModel(service: FakeCareService())
        #expect(model.contacts == .shipped)
        await model.load()
        #expect(model.contacts == CareFixtures.server)
        #expect(model.problem == nil)
        #expect(model.contact(.psc119)?.phone == "112")
        #expect(model.contact(.healing119)?.phone == "119")
    }

    @Test("keeps the shipped list when the server cannot be reached, and keeps the problem")
    func offline() async {
        let model = CareContactsModel(service: FakeCareService(result: .failure(AppProblem())))
        await model.load()
        #expect(model.contacts == .shipped)
        #expect(model.problem?.code == nil)
        #expect(model.contact(.kiraCare) == nil)
    }

    @Test("a lost connection keeps the shipped list and is kept as connection loss")
    func connectionLoss() async {
        let model = CareContactsModel(service: FakeCareService(error: URLError(.notConnectedToInternet)))
        await model.load()
        #expect(model.contacts == .shipped)
        #expect(model.problem == .connectionLost)
    }
}

@MainActor
@Suite("TrustedMessageModel")
struct TrustedMessageModelTests {
    @Test("fills in the opening message and links WhatsApp, SMS and the call to Layanan Kira")
    func links() async {
        let model = TrustedMessageModel(service: FakeCareService(), message: "Halo, aku lagi nggak baik-baik saja.")
        #expect(model.whatsAppURL == nil)
        await model.load()
        #expect(
            model.whatsAppURL?.absoluteString
                == "https://wa.me/6281234567890?text=Halo,%20aku%20lagi%20nggak%20baik-baik%20saja.")
        #expect(model.smsURL?.absoluteString == "sms:081234567890&body=Halo,%20aku%20lagi%20nggak%20baik-baik%20saja.")
        #expect(model.callURL?.absoluteString == "tel:081234567890")
        model.message = "Tolong telepon aku"
        #expect(model.smsURL?.absoluteString == "sms:081234567890&body=Tolong%20telepon%20aku")
    }

    @Test("has nothing to open without Layanan Kira's contact, and keeps the message")
    func noRecipient() async {
        let model = TrustedMessageModel(service: FakeCareService(result: .failure(AppProblem())), message: "Halo")
        model.message = "Halo, tolong"
        await model.load()
        #expect(model.whatsAppURL == nil)
        #expect(model.smsURL == nil)
        #expect(model.callURL == nil)
        #expect(model.message == "Halo, tolong")
        #expect(model.contacts.problem != nil)
    }
}
