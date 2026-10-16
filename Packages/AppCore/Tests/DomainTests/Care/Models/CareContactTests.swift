import Foundation
import Testing

@testable import Domain

@Suite("CareContact")
struct CareContactTests {
    private let ojk = CareContact(key: .ojk157, name: "OJK 157", phone: "157", whatsApp: "081157157157", note: "n")

    @Test("calls the number, then the extension after a pause")
    func call() {
        #expect(CareContactList.shipped.contact(.healing119)?.callURL?.absoluteString == "tel:119,8")
        #expect(ojk.callURL?.absoluteString == "tel:157")
        let international = CareContact(key: .kiraCare, name: "K", phone: "+62 811-2345", note: "n")
        #expect(international.callURL?.absoluteString == "tel:+628112345")
    }

    @Test("opens WhatsApp in international form, the message typed in only when not blank")
    func whatsApp() {
        #expect(ojk.whatsAppURL(message: nil)?.absoluteString == "https://wa.me/6281157157157")
        #expect(ojk.whatsAppURL(message: "  \n")?.absoluteString == "https://wa.me/6281157157157")
        #expect(
            ojk.whatsAppURL(message: "Halo, bisa & mau?")?.absoluteString
                == "https://wa.me/6281157157157?text=Halo,%20bisa%20%26%20mau%3F")
        let international = CareContact(key: .kiraCare, name: "K", whatsApp: "628111", note: "n")
        #expect(international.whatsAppURL(message: nil)?.absoluteString == "https://wa.me/628111")
    }

    @Test("opens Messages with the number and the body")
    func sms() {
        #expect(ojk.smsURL(message: nil)?.absoluteString == "sms:157")
        #expect(ojk.smsURL(message: "Halo +1=2")?.absoluteString == "sms:157&body=Halo%20%2B1%3D2")
    }

    @Test("has no link for a missing or empty number")
    func missing() {
        let web = CareContact(key: .iasc, name: "IASC", website: URL(string: "https://iasc.ojk.go.id"), note: "n")
        #expect(web.callURL == nil)
        #expect(web.smsURL(message: "x") == nil)
        #expect(web.whatsAppURL(message: "x") == nil)
        let empty = CareContact(key: .kiraCare, name: "K", phone: "-", whatsApp: "-", note: "n")
        #expect(empty.callURL == nil)
        #expect(empty.smsURL(message: nil) == nil)
        #expect(empty.whatsAppURL(message: nil) == nil)
    }
}

@Suite("CareContactList")
struct CareContactListTests {
    @Test("the shipped list is the server's seed, without Layanan Kira until its number is confirmed")
    func shipped() {
        let list = CareContactList.shipped
        #expect(list.verifiedOn == CalendarDay(year: 2026, month: 10, day: 1))
        #expect(list.contacts.map(\.key) == [.healing119, .psc119, .ojk157, .satgasPasti, .iasc, .lapsSjk])
        #expect(list.contact(.kiraCare) == nil)
        #expect(list.contact(.psc119)?.callURL?.absoluteString == "tel:119")
    }

    @Test("falls back to the shipped contact the server's list lacks")
    func orShipped() {
        let kira = CareContact(key: .kiraCare, name: "Layanan Kira Peduli", phone: "0811", note: "n")
        let list = CareContactList(verifiedOn: CalendarDay(year: 2026, month: 11, day: 1), contacts: [kira])
        #expect(list.contactOrShipped(.kiraCare) == kira)
        #expect(list.contact(.psc119) == nil)
        #expect(list.contactOrShipped(.psc119)?.name == "PSC 119")
        #expect(CareContactKey(rawValue: "laps_sjk") == .lapsSjk)
    }
}
