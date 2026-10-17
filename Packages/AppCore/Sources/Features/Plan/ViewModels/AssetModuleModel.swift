import Domain
import Observation

/**
 One asset-class module (REN-08): static education content from the String Catalog, read part by
 part. It opens on part 2, as the board draws it; Bagian Berikutnya moves on, and on the last part
 the button finishes the module.
 */
@MainActor
@Observable
package final class AssetModuleModel {
    /** The class the module teaches. */
    package let assetClass: AssetClass
    /** The part on screen. */
    package private(set) var part: AssetModulePart = .basics

    /** The module of `assetClass`, on its first drawn part. */
    package init(assetClass: AssetClass) {
        self.assetClass = assetClass
    }

    /** Whether the button finishes the module instead of moving on. */
    package var isLastPart: Bool { part.next == nil }

    /** Moves to the next part; false on the last part, where the caller closes the module. */
    package func advance() -> Bool {
        guard let next = part.next else { return false }
        part = next
        return true
    }
}
