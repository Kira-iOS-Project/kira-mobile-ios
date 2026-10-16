import Foundation


/**
 The word a person types to delete their account (AKN-05): "HAPUS", in any case, with spaces
 around it ignored, as the API's `POST /me/deletion` checks it.
 */
package enum DeletionConfirmation {
    /** The word to type. */
    package static let word = "HAPUS"

    /** Whether `text` confirms the deletion. */
    package static func accepts(_ text: String) -> Bool {
        text.trimmingCharacters(in: .whitespacesAndNewlines).uppercased() == word
    }
}
