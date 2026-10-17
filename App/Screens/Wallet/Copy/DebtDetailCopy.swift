/** Detail Utang's words for Domain values: rupiah inside sentences (the kind's icon is DebtKind+Display's). */
import Domain
import Foundation

/** Figures Detail Utang writes inside sentences. */
enum DebtCopy {
    /** "Rp210.000,00". */
    static func rupiah(_ amount: Int) -> String {
        RupiahFormatStyle().format(amount.rupiah)
    }
}
