/**
 The name Kira greets a person by. Kira never asks for a name (owner decision): it is the letters
 at the start of the email's local part, capitalised, so "dinda@…" and "dinda.r93@…" are "Dinda".
 */

/** The greeting name derived from an email address. */
package enum DisplayName {
    /** The leading letters of the local part, capitalised, or nil when it starts with no letter. */
    package static func from(email: String) -> String? {
        let letters = email.prefix { $0.isLetter }
        guard let first = letters.first else { return nil }
        return first.uppercased() + letters.dropFirst().lowercased()
    }
}
