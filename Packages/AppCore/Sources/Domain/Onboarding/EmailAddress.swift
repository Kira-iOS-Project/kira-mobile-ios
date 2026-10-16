import Foundation

/**
 The email a person signs up or signs in with (ONB-05, ONB-06). The app checks only its shape
 before asking for a code; whether an account exists is never told (the server answers the same).
 */

/** Checks and tidies an email address as typed. */
package enum EmailAddress {
    /** The address without spaces around it and in lower case, as the server keys accounts. */
    package static func normalized(_ input: String) -> String {
        input.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    /**
     Whether `input`, once normalized, looks like an address: one "@", something before it, and a
     domain with a dot that neither starts nor ends it, and no spaces anywhere.
     */
    package static func isValid(_ input: String) -> Bool {
        let address = normalized(input)
        let parts = address.split(separator: "@", omittingEmptySubsequences: false)
        guard parts.count == 2, !address.contains(" ") else { return false }
        let local = parts[0]
        let domain = parts[1]
        guard !local.isEmpty, domain.contains(".") else { return false }
        return !domain.hasPrefix(".") && !domain.hasSuffix(".") && !domain.contains("..")
    }
}
