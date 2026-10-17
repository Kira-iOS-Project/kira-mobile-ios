import Foundation

/**
 Naskah Pengajuan Keringanan (PED-09): the values a fixed template is filled with, on the device.
 The contract number stays in memory for the screen only and is never sent or stored: the screen
 shows it masked ("••••4821"), and the copied text carries it whole, for the person's own lender.
 */
package struct NegotiationScript: Hashable, Sendable {
    /** What stands for the hidden characters of the contract number. */
    package static let mask = "••••"

    /** The person's name, from the account ("Dinda"); empty when it could not be read. */
    package var name: String
    /** The contract number as typed; empty until the person fills it in. */
    package var contractNumber: String
    /** The instalment today, in whole rupiah. */
    package var currentInstalment: Int?
    /** What the person can pay each month, in whole rupiah. */
    package var affordable: Int?
    /** The short reason, the script's editable phrase ("penghasilan berkurang"). */
    package var reason: String

    /** A script with the given values. */
    package init(
        name: String, contractNumber: String = "", currentInstalment: Int? = nil, affordable: Int? = nil,
        reason: String
    ) {
        self.name = name
        self.contractNumber = contractNumber
        self.currentInstalment = currentInstalment
        self.affordable = affordable
        self.reason = reason
    }

    /** The contract number's letters and digits, without spaces or dashes. */
    package var contractCharacters: String {
        contractNumber.filter { $0.isLetter || $0.isNumber }
    }

    /**
     "••••" and the contract number's last characters: four, or half of a number shorter than eight,
     so a short number never shows whole; nil while none is typed.
     */
    package var maskedContract: String? {
        let characters = contractCharacters
        guard !characters.isEmpty else { return nil }
        return Self.mask + String(characters.suffix(min(4, characters.count / 2)))
    }

    /** The reason without surrounding spaces; nil while it is empty. */
    package var trimmedReason: String? {
        let trimmed = reason.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    /** Whether Salin Naskah may copy: both amounts and a reason. The contract number may stay a gap. */
    package var isComplete: Bool {
        currentInstalment != nil && affordable != nil && trimmedReason != nil
    }

    /** Where the filled script goes: the screen masks the contract number, the clipboard carries it whole. */
    package enum Audience: Hashable, Sendable {
        /** On screen, the contract number masked. */
        case screen
        /** Copied for the person's lender, the contract number whole. */
        case clipboard
    }

    /** The template's five values, in its order; a nil name or contract number is a gap the person fills. */
    package struct Fill: Hashable, Sendable {
        /** The person's name; nil when the account could not be read. */
        package let name: String?
        /** The contract number as the audience sees it; nil while none is typed. */
        package let contract: String?
        /** The instalment today, in whole rupiah. */
        package let instalment: Int
        /** The reason. */
        package let reason: String
        /** What the person can pay each month, in whole rupiah. */
        package let affordable: Int
    }

    /** The values the fixed template is filled with for `audience`. */
    package func fill(for audience: Audience) -> Fill {
        let contract = audience == .screen ? maskedContract : (contractCharacters.isEmpty ? nil : contractNumber)
        return Fill(
            name: name.isEmpty ? nil : name, contract: contract, instalment: currentInstalment ?? 0,
            reason: trimmedReason ?? reason, affordable: affordable ?? 0)
    }
}
