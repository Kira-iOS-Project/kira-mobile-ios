import APIClient
import Domain
import Foundation

@testable import Features

/** A canned account, the board's Dinda. */
enum Sample {
    static let day = Date(timeIntervalSince1970: 1_793_491_200)
    static let usage = AccountUsage(
        aiMessages: UsageMeter(used: 18, limit: 30), receipts: UsageMeter(used: 4, limit: 10),
        voiceSeconds: UsageMeter(used: 0, limit: 0), resetsOn: day)

    static func profile(hidesBalances: Bool = false) -> AccountProfile {
        AccountProfile(
            id: "u1", email: "dinda@email.com", displayName: "Dinda", plan: AccountPlan(id: .free), usage: usage,
            period: PayPeriod(start: day, end: day), debtAccountCount: 3, hidesBalances: hidesBalances,
            aiEnabled: true, weeklySummaryEnabled: true)
    }

    static func consents(ai: Bool = true, weekly: Bool = true) -> ConsentSettings {
        ConsentSettings(
            policyVersion: "2026-10-15",
            items: [
                ConsentItem(purpose: .core, granted: true), ConsentItem(purpose: .aiProcessing, granted: ai),
                ConsentItem(purpose: .weeklySummary, granted: weekly),
            ])
    }

    static let problem = AppProblem(code: "INTERNAL_ERROR", requestId: "req-1")
    static let export = DataExport(fileName: "kira-data-2026-10-16.csv", csv: Data("tanggal\n".utf8))
}

/** The account API, answering from what each test sets; a nil result throws `Sample.problem`. */
actor FakeAccountService: AccountService {
    var profileResult: AccountProfile?
    var consentsResult: ConsentSettings?
    var exportResult: DataExport?
    var fails = false
    private(set) var calls: [String] = []

    init(profile: AccountProfile? = Sample.profile(), consents: ConsentSettings? = Sample.consents()) {
        profileResult = profile
        consentsResult = consents
        exportResult = Sample.export
    }

    func set(fails: Bool) { self.fails = fails }
    func set(profile: AccountProfile?) { profileResult = profile }

    func profile() async throws -> AccountProfile {
        calls.append("profile")
        return try value(profileResult)
    }

    func setHidesBalances(_ hidden: Bool) async throws -> AccountProfile {
        calls.append("setHidesBalances \(hidden)")
        _ = try value(fails ? nil : profileResult)
        return Sample.profile(hidesBalances: hidden)
    }

    func consents() async throws -> ConsentSettings {
        calls.append("consents")
        return try value(consentsResult)
    }

    func updateConsents(aiProcessing: Bool, weeklySummary: Bool) async throws -> ConsentSettings {
        calls.append("updateConsents \(aiProcessing) \(weeklySummary)")
        _ = try value(fails ? nil : consentsResult)
        return Sample.consents(ai: aiProcessing, weekly: weeklySummary)
    }

    func exportData() async throws -> DataExport {
        calls.append("exportData")
        return try value(fails ? nil : exportResult)
    }

    func emailExport() async throws {
        calls.append("emailExport")
        _ = try value(fails ? nil : ())
    }

    func deleteAccount(confirmation: String) async throws {
        calls.append("deleteAccount \(confirmation)")
        _ = try value(fails ? nil : ())
    }

    func signOut() async throws {
        calls.append("signOut")
        _ = try value(fails ? nil : ())
    }

    private func value<T>(_ result: T?) throws -> T {
        guard let result else { throw Sample.problem }
        return result
    }
}

/** The device's PIN store and lock settings, in memory. */
actor FakeSecuritySettings: SecuritySettings {
    private(set) var storedPin: String?
    private(set) var autoLock = AutoLockDelay.immediately
    private(set) var obscures = true
    private(set) var cleared = false
    var savingFails = false

    init(pin: String? = "123456") {
        storedPin = pin
    }

    func set(savingFails: Bool) { self.savingFails = savingFails }

    func preferences() async -> SecurityPreferences {
        SecurityPreferences(isPinLockEnabled: storedPin != nil, autoLock: autoLock, obscuresAppSwitcher: obscures)
    }

    func verifyPin(_ pin: String) async -> Bool { pin == storedPin }

    func setPin(_ pin: String) async throws {
        if savingFails { throw Sample.problem }
        storedPin = pin
    }

    func disablePinLock() async { storedPin = nil }
    func setAutoLock(_ delay: AutoLockDelay) async { autoLock = delay }
    func setObscuresAppSwitcher(_ isOn: Bool) async { obscures = isOn }
    func clearLocalData() async { cleared = true }
}

/** Counts a callback's calls. */
@MainActor
final class CallCounter {
    private(set) var count = 0
    func call() { count += 1 }
}
