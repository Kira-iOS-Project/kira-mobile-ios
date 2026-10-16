import APIClient
import Domain
import Foundation
import Testing

@testable import Features

private let tokens = SessionTokens(accessToken: "a", refreshToken: "r", accessExpiresInSeconds: 900)

@MainActor
@Suite("LiveAccountService")
struct LiveAccountServiceTests {
    private let recorder = HideBalancesRecorder()

    private func service(_ replies: [String: RoutedTransport.Reply]) async throws
        -> (LiveAccountService, RoutedTransport, SessionStore)
    {
        let (api, transport) = KiraAPI.routed(replies)
        let session = SessionStore(vault: InMemoryVault()) { _ in .rejected }
        try await session.signIn(tokens, email: "dinda@email.com")
        let service = LiveAccountService(
            api: api, session: session, now: { Date(timeIntervalSince1970: 1_792_130_000) },
            onHideBalances: recorder.sync)
        return (service, transport, session)
    }

    @Test("GET /me becomes the profile: plan, quotas, period and settings")
    func profile() async throws {
        let (service, _, _) = try await service(["GET /api/me": ok(meJSON())])
        let profile = try await service.profile()
        #expect(profile.email == "dinda@email.com" && profile.displayName == "Dinda" && profile.debtAccountCount == 2)
        #expect(profile.plan == AccountPlan(
            id: .plus, source: .scholarship, renewsOn: CalendarDay(year: 2027, month: 1, day: 16).date))
        #expect(profile.usage.aiMessages == UsageMeter(used: 3, limit: 30))
        #expect(profile.usage.resetsOn == CalendarDay(year: 2026, month: 11, day: 1))
        #expect(profile.period.end == CalendarDay(year: 2026, month: 10, day: 24))
        #expect(!profile.hidesBalances && profile.aiEnabled && !profile.weeklySummaryEnabled)
    }

    @Test("a free plan has no source or renewal")
    func freePlan() async throws {
        let (service, _, _) = try await service([
            "GET /api/me": ok(meJSON(plan: #"{"id":"free","source":null,"renewsOn":null}"#))
        ])
        #expect(try await service.profile().plan == AccountPlan(id: .free))
    }

    @Test("Sembunyikan Saldo is saved to the account and handed to the lock")
    func hidesBalances() async throws {
        let (service, transport, _) = try await service(["PATCH /api/me": ok(meJSON(hideBalances: true))])
        #expect(try await service.setHidesBalances(true).hidesBalances)
        #expect(await transport.sent.first?.json == ["hideBalances": .bool(true)])
        #expect(recorder.values == [true])
    }

    @Test("consents are read and changed")
    func consents() async throws {
        let (service, transport, _) = try await service([
            "GET /api/me/consents": ok(consentsJSON), "PUT /api/me/consents": ok(consentsJSON),
        ])
        let consents = try await service.consents()
        #expect(consents.policyVersion == "2026-10-15")
        #expect(consents.items.map(\.purpose) == [.core, .weeklySummary])
        #expect(consents.items[0].decidedAt == Date(timeIntervalSince1970: 1_792_126_800))
        #expect(consents.items[1] == ConsentItem(purpose: .weeklySummary, granted: false))
        _ = try await service.updateConsents(aiProcessing: true, weeklySummary: false)
        #expect(await transport.sent.last?.json == ["aiProcessing": .bool(true), "weeklySummary": .bool(false)])
    }

    @Test("the export is named after today in WIB; emailing it calls the API")
    func export() async throws {
        let csv = "tanggal,jam\n2026-10-16,08.12\n"
        let (service, transport, _) = try await service([
            "GET /api/me/export": RoutedTransport.Reply(status: 200, body: csv, contentType: "text/csv"),
            "POST /api/me/export/email": empty(202),
        ])
        let export = try await service.exportData()
        #expect(export.fileName == "kira-data-2026-10-16.csv")
        #expect(export.csv == Data(csv.utf8))
        try await service.emailExport()
        #expect(await transport.routes.last == "POST /api/me/export/email")
    }

    @Test("deleting the account ends the session on this device")
    func delete() async throws {
        let (service, transport, session) = try await service(["POST /api/me/deletion": empty()])
        try await service.deleteAccount(confirmation: "HAPUS")
        #expect(await transport.sent.first?.json == ["confirmation": .string("HAPUS")])
        #expect(!session.hasSession)
    }

    @Test("signing out forgets the session, also when the API cannot be reached")
    func signOut() async throws {
        let (service, _, session) = try await service(["POST /api/auth/sign-out": empty()])
        try await service.signOut()
        #expect(!session.hasSession)
        let (failing, _, failingSession) = try await self.service(["POST /api/auth/sign-out": problem("INTERNAL_ERROR", status: 401)])
        await #expect(throws: AppProblem.self) { try await failing.signOut() }
        #expect(!failingSession.hasSession)
    }
}
