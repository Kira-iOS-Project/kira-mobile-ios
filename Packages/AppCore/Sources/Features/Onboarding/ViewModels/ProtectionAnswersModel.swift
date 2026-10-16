import Domain
import Observation

/**
 Tanggungan dan Proteksi (ONB-12): dependents and marital status are one choice each; protections
 allow several, and "Belum Ada" clears the others.
 */
@MainActor @Observable
package final class ProtectionAnswersModel {
    /** The most dependents a chip counts ("3 Orang atau Lebih"). */
    package static let maximumDependents = 3

    /** People who depend on the person, 0 to 3. */
    package var dependents = 0
    /** Belum Menikah or Sudah Menikah. */
    package var maritalStatus = MaritalStatus.single
    /** The protections chosen. */
    package private(set) var protections: Set<Protection> = []
    /** Whether "Belum Ada" is chosen. */
    package private(set) var hasNone = false

    /** Nothing chosen beyond the defaults: no dependents, single. */
    package init() {}

    /** Taps the chip of `protection`. */
    package func toggle(_ protection: Protection) {
        if protections.remove(protection) == nil { protections.insert(protection) }
        if !protections.isEmpty { hasNone = false }
    }

    /** Taps "Belum Ada". */
    package func toggleNone() {
        hasNone.toggle()
        if hasNone { protections = [] }
    }
}
