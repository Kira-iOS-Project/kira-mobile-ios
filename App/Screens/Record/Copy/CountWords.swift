/**
 Catat's counts in words ("Tiga transaksi tersimpan."). Dates and times come from
 App/Screens/Shared/Copy/KiraFormats.swift, categories from Shared/Copy/TransactionCategory+Display.swift.
 */
import SwiftUI

/** A count in words, "Tiga", for "Tiga transaksi tersimpan."; above ten in digits. */
func countWord(_ count: Int) -> Text {
    switch count {
    case 2: Text("record.count.two")
    case 3: Text("record.count.three")
    case 4: Text("record.count.four")
    case 5: Text("record.count.five")
    case 6: Text("record.count.six")
    case 7: Text("record.count.seven")
    case 8: Text("record.count.eight")
    case 9: Text("record.count.nine")
    case 10: Text("record.count.ten")
    default: Text(count, format: .number)
    }
}
