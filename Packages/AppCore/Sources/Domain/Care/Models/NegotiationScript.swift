import Foundation

/**
 Naskah Pengajuan Keringanan (PED-09): the values a fixed template is filled with, on the device.
 The contract number stays in memory for the screen only and is never sent or stored: the screen
 shows it masked ("••••4821"), and the copied text carries it whole, for the person's own lender.
 */
package struct NegotiationScript: Hashable, Sendable {
    /** What stands for the hidden characters of the contract number. */
    package static let mask = "••••"

    /** The person's name, from the account ("Dinda"). */
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

    /** "••••" and the last four characters of the contract number; nil while none is typed. */
    package var maskedContract: String? {
        let characters = contractCharacters
        guard !characters.isEmpty else { return nil }
        return Self.mask + String(characters.suffix(4))
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
}
