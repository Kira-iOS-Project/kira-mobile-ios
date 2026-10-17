/** The Dompet board's accounts, with fixed due dates (no clock in the app's previews). */
import Domain
import Foundation

nonisolated enum WalletPreviewData {
    static var accounts: [Wallet] {
        [
            Wallet(id: "bank-salary", name: "Rekening Gaji", type: .bank, balance: 2_140_000),
            Wallet(id: "ewallet-main", name: "Dompet Digital", type: .ewallet, balance: 312_000),
            Wallet(id: "cash-main", name: "Tunai", type: .cash, balance: 150_000),
            Wallet(id: "bank-emergency", name: "Tabungan Dana Darurat", type: .bank, balance: 4_800_000),
            Wallet(id: "paylater-a", name: "Paylater A", type: .paylater, balance: 420_000, nextDueAt: day(25, 10)),
            Wallet(id: "paylater-b", name: "Paylater B", type: .paylater, balance: 1_150_000, nextDueAt: day(5, 11)),
            Wallet(id: "motor", name: "Cicilan Motor", type: .vehicle, balance: 12_740_000, nextDueAt: day(28, 10)),
        ]
    }

    /** Noon WIB on that day of 2026, the board's year. */
    private static func day(_ day: Int, _ month: Int) -> Date {
        var parts = DateComponents(year: 2026, month: month, day: day, hour: 12)
        parts.timeZone = TimeZone(identifier: "Asia/Jakarta")
        return Calendar(identifier: .gregorian).date(from: parts) ?? .distantPast
    }
}
