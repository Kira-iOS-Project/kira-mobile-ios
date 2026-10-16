/**
 How every screen words a problem (AGENTS.md Rule 12): the catalog's message for its code
 (`problem.<CODE>`), or the generic one with the reference a person quotes to support.
 */
import APIClient
import Foundation

extension AppProblem {
    /** The catalog's message for this problem: its code's, or `problem.unknown`. */
    var message: LocalizedStringResource {
        LocalizedStringResource(String.LocalizationValue(messageKey))
    }

    /** The reference to quote to support, shown under the generic message only. */
    var unknownReference: String? {
        knownCode == nil ? reference : nil
    }
}
