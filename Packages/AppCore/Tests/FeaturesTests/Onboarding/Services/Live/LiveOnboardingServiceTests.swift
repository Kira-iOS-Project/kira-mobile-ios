import APIClient
import Domain
import Testing

@testable import Features

@MainActor
@Suite("LiveOnboardingService")
struct LiveOnboardingServiceTests {
    private let recorder = HideBalancesRecorder()

    private func service(_ replies: [String: RoutedTransport.Reply], session: SessionStore = newSession())
        -> (LiveOnboardingService, RoutedTransport)
    {
        let (api, transport) = KiraAPI.routed(replies)
        return (LiveOnboardingService(api: api, session: session, onHideBalances: recorder.sync), transport)
    }

    @Test("a code request returns its two durations")
    func requestCode() async throws {
        let (service, transport) = service([
            "POST /api/auth/code": ok(#"{"expiresInSeconds":600,"resendAfterSeconds":60}"#, status: 202)
        ])
        let delivery = try await service.requestCode(email: "dinda@email.com")
        #expect(delivery == CodeDelivery(resendAfterSeconds: 60))
        #expect(await transport.sent.first?.json["email"] == .string("dinda@email.com"))
    }

    @Test("a right code starts the session on this device and says whether onboarding is needed")
    func verify() async throws {
        let session = newSession()
        let (service, _) = service(
            ["POST /api/auth/verify": ok("{\(tokensJSON),\"needsOnboarding\":true}")], session: session)
        #expect(
            try await service.verify(email: "dinda@email.com", code: "381449") == SignInResult(needsOnboarding: true))
        #expect(session.hasSession && session.accountEmail == "dinda@email.com")
        #expect(await session.bearerToken() == "a-1")
    }

    @Test("a wrong code keeps the device signed out and throws the problem")
    func wrongCode() async throws {
        let session = newSession()
        let (service, _) = service(["POST /api/auth/verify": problem("AUTH_CODE_INVALID")], session: session)
        await #expect(throws: AppProblem.self) { try await service.verify(email: "dinda@email.com", code: "000000") }
        #expect(!session.hasSession)
    }

    @Test("consents, focus and the balance choice reach the account; the lock gets the choice")
    func settings() async throws {
        let (service, transport) = service([
            "PUT /api/me/consents": ok(consentsJSON), "PATCH /api/me": ok(meJSON()),
        ])
        try await service.saveConsents(ConsentChoices(aiProcessing: false, weeklySummary: true))
        try await service.saveFocus(.debtFree)
        try await service.saveHideBalances(true)
        let sent = await transport.sent.map(\.json)
        #expect(sent[0] == ["aiProcessing": .bool(false), "weeklySummary": .bool(true)])
        #expect(sent[1] == ["focus": .string("debt_free")])
        #expect(sent[2] == ["hideBalances": .bool(true)])
        #expect(recorder.values == [true])
    }

    @Test("the quiz's answers go out as PUT /health-check and the first score comes back")
    func healthCheck() async throws {
        let (service, transport) = service(["PUT /api/health-check": ok(reportJSON)])
        var answers = HealthCheckAnswers()
        answers.netMonthlyIncome = 7_500_000
        answers.payday = .endOfMonth
        answers.debts = [
            DebtEntry(
                kind: .onlineLoan, name: "Pinjol B", remaining: 900_000, monthlyInstalment: 300_000,
                remainingTenorMonths: 3, annualInterestRate: 36, dueDay: 5)
        ]
        answers.dependents = 2
        answers.maritalStatus = .married
        answers.protections = [.privateHealth, .bpjsHealth]
        let report = try await service.submitHealthCheck(answers)
        #expect(report.score == 66)
        let body = try #require(await transport.sent.first?.json)
        /**
         The generated client leaves a skipped answer out rather than sending null; the API reads a
         missing key as null (kira-backend 6e93a3c), so the spec no longer lists these as required.
         */
        #expect(body["netMonthlyIncome"] == .number(7_500_000) && body["essentialMonthlyExpenses"] == nil)
        #expect(body["payday"] == .object(["endOfMonth": .bool(true)]))
        #expect(body["dependents"] == .number(2) && body["maritalStatus"] == .string("married"))
        #expect(body["protections"] == .array([.string("bpjs_health"), .string("private_health")]))
        #expect(
            body["debts"]
                == .array([
                    .object([
                        "kind": .string("online_loan"), "name": .string("Pinjol B"), "remaining": .number(900_000),
                        "monthlyInstalment": .number(300_000), "remainingTenorMonths": .number(3),
                        "annualInterestRate": .number(36), "dueDay": .number(5),
                    ])
                ]))
    }
}

/** A signed-out session in memory. */
func newSession() -> SessionStore {
    SessionStore(vault: InMemoryVault()) { _ in .rejected }
}
