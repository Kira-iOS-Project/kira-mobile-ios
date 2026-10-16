import Foundation

/**
 Rencana Keselamatanku (PED-10): what the person wrote while calm, to read when things are heavy.
 Five parts: the warning signs, what calms them, people they can reach, professional services, and a
 safe place. Every text is at most 500 characters and may be empty; parts 3 and 4 hold at most three
 contacts each. The server keeps it encrypted, apart from the financial data.
 */
package struct SafetyPlan: Hashable, Sendable {
    /** The longest text a part holds. */
    package static let maximumTextLength = 500
    /** The most contacts part 3 or part 4 holds. */
    package static let maximumContacts = 3

    /** Part 1: Tanda Aku Mulai Berat. */
    package var warningSigns: String
    /** Part 2: Hal yang Menenangkanku. */
    package var calmingThings: String
    /** Part 3: Orang yang Bisa Kuhubungi. */
    package var people: [SafetyContact]
    /** Part 4: Layanan Profesional. */
    package var professionals: [SafetyContact]
    /** Part 5: Tempat Aku Merasa Aman. */
    package var safePlace: String
    /** When it was last saved; nil for a plan never saved. */
    package var updatedAt: Date?

    /** A plan with the given parts; empty unless told otherwise. */
    package init(
        warningSigns: String = "", calmingThings: String = "", people: [SafetyContact] = [],
        professionals: [SafetyContact] = [], safePlace: String = "", updatedAt: Date? = nil
    ) {
        self.warningSigns = warningSigns
        self.calmingThings = calmingThings
        self.people = people
        self.professionals = professionals
        self.safePlace = safePlace
        self.updatedAt = updatedAt
    }

    /** The plan nobody has written yet (`GET /care/safety-plan` answered 404). */
    package static let empty = SafetyPlan()

    /**
     The plan as it is saved: each text trimmed and cut to 500 characters, contacts without a name
     or a number dropped, at most three per part.
     */
    package var cleaned: SafetyPlan {
        SafetyPlan(
            warningSigns: Self.clean(warningSigns), calmingThings: Self.clean(calmingThings),
            people: Self.clean(people), professionals: Self.clean(professionals),
            safePlace: Self.clean(safePlace), updatedAt: updatedAt)
    }

    private static func clean(_ text: String) -> String {
        String(text.trimmingCharacters(in: .whitespacesAndNewlines).prefix(maximumTextLength))
    }

    private static func clean(_ contacts: [SafetyContact]) -> [SafetyContact] {
        let kept = contacts.map { SafetyContact(name: clean($0.name), phone: clean($0.phone)) }
            .filter { !$0.name.isEmpty || !$0.phone.isEmpty }
        return Array(kept.prefix(maximumContacts))
    }
}

/** A person or a service in the plan, with a number the person can tap to call. */
package struct SafetyContact: Hashable, Sendable {
    /** Who it is ("Ibu", "Healing119"). */
    package var name: String
    /** The number as the person wrote it ("119 ext 8", "0812-3456-7890"). */
    package var phone: String

    /** A contact with a name and a number. */
    package init(name: String, phone: String) {
        self.name = name
        self.phone = phone
    }

    /**
     The number to dial, digits and a leading "+" only, with any extension after a pause (",") so the
     phone dials it after the call connects: "119 ekstensi 8" (or "eks", "ext") dials "119,8". Nil
     when there is no digit.
     */
    package var dialable: String? {
        let text = Substring(phone.lowercased())
        let marker = text.firstMatch(of: /ekstensi|eks|ext/)
        let main = Self.digits(marker.map { text[..<$0.range.lowerBound] } ?? text, keepsPlus: true)
        guard main.contains(where: \.isNumber) else { return nil }
        guard let marker else { return main }
        let extensionDigits = Self.digits(text[marker.range.upperBound...], keepsPlus: false)
        return extensionDigits.isEmpty ? main : main + "," + extensionDigits
    }

    private static func digits(_ text: Substring, keepsPlus: Bool) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespaces)
        let plus = keepsPlus && trimmed.hasPrefix("+") ? "+" : ""
        return plus + trimmed.filter { $0.isASCII && $0.isNumber }
    }
}
