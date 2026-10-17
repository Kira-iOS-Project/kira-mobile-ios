/**
 What a ladder step says (REN-01): the board's title and line for each step, the numbers the engine
 gives (step 2's "Dana Darurat 6×", "Sekarang 1,1× pengeluaran pokok"), and the board's tags:
 "Sedang Berjalan" (· what the API names) in progress, "Sudah Aman" once done.
 */
import Domain
import SwiftUI

extension LadderStep {
    /** "Lunasi Utang Mahal", "Dana Darurat 6×", "Proteksi", "Investasi Bertahap". */
    var title: LocalizedStringResource {
        switch key {
        case .expensiveDebt: "plan.ladder.payOffDebt"
        case .emergencyFund:
            if let target = detail.targetMultiple {
                "plan.ladder.emergencyFund.multiple \(Double(target), format: .kiraMultiple)"
            } else {
                "plan.ladder.emergencyFund"
            }
        case .protection: "plan.ladder.protection"
        case .investing: "plan.ladder.invest"
        }
    }

    /** The line under the title; step 2's comes from the engine's multiple, and has none without it. */
    var line: LocalizedStringResource? {
        switch key {
        case .expensiveDebt: "plan.ladder.payOffDebt.line"
        case .emergencyFund:
            detail.multiple.map { "plan.ladder.emergencyFund.line \($0, format: .kiraMultiple)" }
        case .protection: "plan.ladder.protection.line"
        case .investing: "plan.ladder.invest.line"
        }
    }

    /** "Sedang Berjalan · Paylater A" in progress, "Sudah Aman" once done; step 4 has none. */
    var tag: KiraTag? {
        guard key != .investing else { return nil }
        switch status {
        case .current:
            guard let name = detail.debtName else {
                return KiraTag("plan.ladder.current", tone: .turmeric, icon: .clock)
            }
            return KiraTag("plan.ladder.current.named \(name)", tone: .turmeric, icon: .clock)
        case .done: return KiraTag("plan.ladder.done", tone: .healthy, icon: .shield)
        case .todo: return nil
        }
    }

    /** "Langkah 1: Lunasi Utang Mahal…", "Langkah 3, selesai: Proteksi…", read as one line. */
    var accessibilityLabel: Text {
        let lead = status == .done ? Text("plan.ladder.step.done \(step)") : Text("plan.ladder.step \(step)")
        return Text("\(lead)\(Text(title))")
    }
}
