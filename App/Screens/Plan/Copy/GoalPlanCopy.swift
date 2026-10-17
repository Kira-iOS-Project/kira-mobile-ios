/**
 The figures goal screens write inside sentences and formulas: rupiah as "Rp450.000.000,00" and a
 rate's percent as "6,5".
 */
import Domain
import SwiftUI

extension GoalCopy {
    /** "Rp450.000.000,00". */
    static func rupiah(_ amount: Int) -> Text {
        Text(amount.rupiah, format: RupiahFormatStyle())
    }

    /** "5" for 0.05, "6,5" for 0.065. */
    static func percent(_ rate: Double) -> Text {
        Text(rate * 100, format: .kiraMultiple)
    }
}
