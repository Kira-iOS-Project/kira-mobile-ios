/**
 The boards' Dinda: Kira Gratis, 18 of 30 chat messages and 4 of 10 receipts used, the quota
 filling again on 1 November 2026, three debt accounts, pay period 25 September to 24 October.
 Previews show it, and the Profil placeholder draws its layout while the account loads.
 */
import Domain
import Foundation

/** Sample data for the Akun screens. */
nonisolated enum AccountSamples {
    /** A WIB day of 2026. */
    static func day(_ month: Int, _ day: Int) -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Jakarta") ?? .current
        return calendar.date(from: DateComponents(year: 2026, month: month, day: day)) ?? .distantPast
    }

    static let profile = AccountProfile(
        id: "user-dinda", email: "dinda@email.com", displayName: "Dinda", plan: AccountPlan(id: .free),
        usage: Usage(
            aiMessages: UsageMeter(used: 18, limit: 30), receipts: UsageMeter(used: 4, limit: 10),
            voiceSeconds: UsageMeter(used: 0, limit: 0), resetsOn: CalendarDay(day(11, 1))),
        period: PayPeriod(
            start: CalendarDay(year: 2026, month: 9, day: 25), end: CalendarDay(year: 2026, month: 10, day: 24),
            daysUntilPayday: 10),
        debtAccountCount: 3, hidesBalances: true,
        aiEnabled: true, weeklySummaryEnabled: true)

    static func consents(aiProcessing: Bool = true, weekly: Bool = true) -> ConsentSettings {
        ConsentSettings(
            policyVersion: "2026-10-15",
            items: [
                ConsentItem(purpose: .core, granted: true), ConsentItem(purpose: .aiProcessing, granted: aiProcessing),
                ConsentItem(purpose: .weeklySummary, granted: weekly),
            ])
    }

    static let export = DataExport(
        fileName: "kira-data-2026-10-16.csv",
        csv: Data(
            """
            tanggal,jam,jenis,kategori,nama,nominal,sumber,catatan
            2026-10-16,12.41,pengeluaran,makan,Nasi padang,25000,chat,
            """.utf8))
}
