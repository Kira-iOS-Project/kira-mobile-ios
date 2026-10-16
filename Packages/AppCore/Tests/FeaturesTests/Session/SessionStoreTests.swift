import Foundation
import Testing

@testable import Features

/** The refresh endpoint: answers with `outcome` (or throws) and records the refresh tokens sent. */
private actor RefreshEndpoint {
    private(set) var received: [String] = []
    let outcome: RefreshOutcome?

    init(_ outcome: RefreshOutcome?) { self.outcome = outcome }

    func call(_ token: String) async throws -> RefreshOutcome {
        received.append(token)
        await Task.yield()
        guard let outcome else { throw URLError(.notConnectedToInternet) }
        return outcome
    }
}

private actor Flag {
    private(set) var isSet = false
    func set() { isSet = true }
}

private let first = SessionTokens(accessToken: "a1", refreshToken: "r1", accessExpiresInSeconds: 900)
private let second = SessionTokens(accessToken: "a2", refreshToken: "r2", accessExpiresInSeconds: 900)

private func store(
    _ outcome: RefreshOutcome?, vault: InMemoryVault = InMemoryVault(), clock: TestClock = TestClock()
) -> (SessionStore, RefreshEndpoint) {
    let endpoint = RefreshEndpoint(outcome)
    return (SessionStore(vault: vault, now: clock.now) { try await endpoint.call($0) }, endpoint)
}

@Suite("SessionStore")
struct SessionStoreTests {
    @Test("keeps the refresh token and email in the vault, the bearer token in memory")
    func signIn() async throws {
        let vault = InMemoryVault()
        let (session, endpoint) = store(.renewed(second), vault: vault)
        #expect(!session.hasSession)
        #expect(session.accountEmail == nil)
        #expect(await session.bearerToken() == nil)
        try await session.signIn(first, email: "dinda@email.com")
        #expect(session.hasSession)
        #expect(session.accountEmail == "dinda@email.com")
        #expect(vault.data(for: .refreshToken) == Data("r1".utf8))
        #expect(await session.bearerToken() == "a1")
        #expect(await endpoint.received.isEmpty)
    }

    @Test("renews an expired bearer token from the refresh token")
    func renewsExpired() async throws {
        let clock = TestClock()
        let vault = InMemoryVault()
        let (session, endpoint) = store(.renewed(second), vault: vault, clock: clock)
        try await session.signIn(first, email: "dinda@email.com")
        clock.advance(871)
        #expect(await session.bearerToken() == "a2")
        #expect(await endpoint.received == ["r1"])
        #expect(vault.data(for: .refreshToken) == Data("r2".utf8))
    }

    @Test("a token renewed meanwhile replaces the rejected one without a call")
    func renewedMeanwhile() async throws {
        let (session, endpoint) = store(.renewed(second))
        try await session.signIn(first, email: "dinda@email.com")
        #expect(await session.renewedBearerToken(replacing: "a1") == "a2")
        #expect(await session.renewedBearerToken(replacing: "a1") == "a2")
        #expect(await endpoint.received == ["r1"])
    }

    @Test("requests waiting together share one renewal")
    func sharesRenewal() async throws {
        let (session, endpoint) = store(.renewed(second))
        try await session.signIn(first, email: "dinda@email.com")
        async let one = session.renewedBearerToken(replacing: "a1")
        async let two = session.renewedBearerToken(replacing: "a1")
        #expect(await [one, two] == ["a2", "a2"])
        #expect(await endpoint.received == ["r1"])
    }

    @Test("a refused refresh token ends the session")
    func rejected() async throws {
        let (session, _) = store(.rejected)
        let ended = Flag()
        await session.setSessionEndedHandler { await ended.set() }
        try await session.signIn(first, email: "dinda@email.com")
        #expect(await session.renewedBearerToken(replacing: "a1") == nil)
        #expect(await ended.isSet)
        #expect(!session.hasSession)
        #expect(session.accountEmail == nil)
    }

    @Test("an unreachable API keeps the session")
    func unreachable() async throws {
        let (session, _) = store(nil)
        try await session.signIn(first, email: "dinda@email.com")
        #expect(await session.renewedBearerToken(replacing: "a1") == nil)
        #expect(session.hasSession)
    }

    @Test("an unreadable refresh token renews nothing")
    func unreadable() async {
        let (session, endpoint) = store(.renewed(second), vault: InMemoryVault([.refreshToken: Data([0xFF])]))
        #expect(await session.bearerToken() == nil)
        #expect(await endpoint.received.isEmpty)
    }

    @Test("signing out forgets everything")
    func signOut() async throws {
        let session = SessionStore(vault: InMemoryVault()) { _ in .rejected }
        try await session.signIn(first, email: "dinda@email.com")
        await session.signOut()
        #expect(!session.hasSession)
        #expect(await session.bearerToken() == nil)
    }
}
