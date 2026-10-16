import Foundation
import Testing

@testable import Domain

@Suite("Account values")
struct AccountValuesTests {
    private func profile(name: String, email: String) -> AccountProfile {
        let meter = UsageMeter(used: 0, limit: 30)
        let day = Date(timeIntervalSince1970: 0)
        return AccountProfile(
            id: "u1", email: email, displayName: name,
            plan: AccountPlan(id: .plus, source: .scholarship, renewsOn: day),
            usage: Usage(aiMessages: meter, receipts: meter, voiceSeconds: meter, resetsOn: CalendarDay(day)),
            period: PayPeriod(start: CalendarDay(day), end: CalendarDay(day), daysUntilPayday: 1), debtAccountCount: 0,
            hidesBalances: false, aiEnabled: true,
            weeklySummaryEnabled: false)
    }

    @Test("the avatar's letter is the name's first, else the email's, in capitals")
    func initial() {
        #expect(profile(name: "dinda", email: "dinda@email.com").initial == "D")
        #expect(profile(name: "", email: "rani@email.com").initial == "R")
        #expect(profile(name: "", email: "").initial.isEmpty)
    }

    @Test("core is always granted; the others follow their decision")
    func consents() {
        let settings = ConsentSettings(
            policyVersion: "1",
            items: [
                ConsentItem(purpose: .aiProcessing, granted: true),
                ConsentItem(purpose: .weeklySummary, granted: false),
            ])
        #expect(settings.isGranted(.core))
        #expect(settings.isGranted(.aiProcessing))
        #expect(!settings.isGranted(.weeklySummary))
    }

    @Test("auto-lock delays in seconds", arguments: zip(AutoLockDelay.allCases, [0, 60, 300]))
    func autoLock(delay: AutoLockDelay, seconds: Int) {
        #expect(delay.seconds == seconds)
    }

    @Test("HAPUS confirms in any case, spaces ignored", arguments: ["HAPUS", "hapus", " Hapus\n"])
    func confirms(text: String) {
        #expect(DeletionConfirmation.accepts(text))
    }

    @Test("anything else does not confirm", arguments: ["", "HAPU", "HAPUS AKUN", "hapus!"])
    func refuses(text: String) {
        #expect(!DeletionConfirmation.accepts(text))
    }

    @Test("the export and the security values keep what they are given")
    func values() {
        let export = DataExport(fileName: "kira-data-2026-10-16.csv", csv: Data())
        #expect(export.fileName == "kira-data-2026-10-16.csv")
        let preferences = SecurityPreferences(isPinLockEnabled: true, autoLock: .oneMinute, obscuresAppSwitcher: false)
        #expect(preferences.autoLock == .oneMinute)
    }
}
