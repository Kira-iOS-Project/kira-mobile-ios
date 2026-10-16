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
                website: URL(string: "https://healing119.id"),
                note: "Free mental-health counselling by health workers."),
            CareContact(
                key: .psc119, name: "PSC 119", phone: "119",
                note: "Public safety centre for medical emergencies, in every regency and city."),
            CareContact(
                key: .ojk157, name: "OJK 157", phone: "157", whatsApp: "081157157157",
                note: "The financial services authority: complaints about lenders and collection."),
            CareContact(
                key: .satgasPasti, name: "Satgas PASTI", website: URL(string: "https://sipasti.ojk.go.id"),
                note: "Reports of illegal lending and investment."),
            CareContact(
                key: .iasc, name: "IASC", website: URL(string: "https://iasc.ojk.go.id"),
                note: "Anti-scam centre: blocks accounts used in a fraud."),
            CareContact(
                key: .lapsSjk, name: "LAPS SJK", website: URL(string: "https://lapssjk.id"),
                note: "Dispute resolution when a complaint to the lender is not settled."),
        ])
}
