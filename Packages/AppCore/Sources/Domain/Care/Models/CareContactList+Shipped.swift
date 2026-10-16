import Foundation

extension CareContactList {
    /**
     The list the app ships, the server's seed as verified on 1 October 2026. Kira Peduli shows it
     until `GET /care/contacts` answers, and keeps it when the server cannot be reached. Layanan
     Kira Peduli is left out, as the server leaves it out, until its number is confirmed.
     */
    package static let shipped = CareContactList(
        verifiedOn: CalendarDay(year: 2026, month: 10, day: 1),
        contacts: [
            CareContact(
                key: .healing119, name: "Healing119", phone: "119", phoneExtension: "8",
                website: URL(string: "https://healing119.id")),
            CareContact(
                key: .psc119, name: "PSC 119", phone: "119"),
            CareContact(
                key: .ojk157, name: "OJK 157", phone: "157", whatsApp: "081157157157"),
            CareContact(
                key: .satgasPasti, name: "Satgas PASTI", website: URL(string: "https://sipasti.ojk.go.id")),
            CareContact(
                key: .iasc, name: "IASC", website: URL(string: "https://iasc.ojk.go.id")),
            CareContact(
                key: .lapsSjk, name: "LAPS SJK", website: URL(string: "https://lapssjk.id")),
        ])
}
