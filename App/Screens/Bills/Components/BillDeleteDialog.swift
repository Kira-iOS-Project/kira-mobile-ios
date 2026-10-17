/**
 Hapus Tagihan Ini? (UNG-07d), over Ubah Tagihan: names the bill, its amount and how often it
 repeats, says it leaves Beranda and the bill list while the transactions already recorded stay.
 Hapus (destructive) on top deletes the schedule; Batal under it closes without a change.
 */
import Domain
import SwiftUI

/** How often a bill repeats, as the confirmation says it. */
enum BillRepeat {
    case once, monthly, yearly
}

extension View {
    /** The confirmation while `isPresented` is true; Hapus runs `onDelete`. */
    func billDeleteDialog(
        isPresented: Binding<Bool>, name: String, amount: Int, repeats: BillRepeat, onDelete: @escaping () -> Void
    ) -> some View {
        kiraDialog(isPresented: isPresented) {
            BillDeleteDialog.dialog(name: name, amount: amount, repeats: repeats, onDelete: onDelete)
        }
    }
}

enum BillDeleteDialog {
    /** The dialog itself, also shown inline in the gallery. */
    static func dialog(name: String, amount: Int, repeats: BillRepeat, onDelete: @escaping () -> Void) -> KiraDialog {
        KiraDialog(
            "bill.delete.title", message: message(name: name, amount: amount, repeats: repeats),
            art: .illustration(.calendar),
            primary: KiraButton("bill.delete.confirm", variant: .destructive, action: onDelete),
            secondary: KiraButton("bill.delete.cancel", variant: .secondary) {})
    }

    private static func message(name: String, amount: Int, repeats: BillRepeat) -> LocalizedStringResource {
        switch repeats {
        case .once: "bill.delete.body.once \(name) \(amount.rupiah, format: .rupiah)"
        case .monthly: "bill.delete.body.monthly \(name) \(amount.rupiah, format: .rupiah)"
        case .yearly: "bill.delete.body.yearly \(name) \(amount.rupiah, format: .rupiah)"
        }
    }
}
