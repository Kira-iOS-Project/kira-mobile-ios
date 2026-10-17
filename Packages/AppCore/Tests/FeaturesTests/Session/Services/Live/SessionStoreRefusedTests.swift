import Foundation
import Testing

@testable import Features

/** Counts how often the session ended. */
private actor Endings {
    private(set) var events: [String] = []
    func record() { events.append("ended") }
}

@Suite("SessionStore refused token")
struct SessionStoreRefusedTests {
    private let tokens = SessionTokens(accessToken: "a1", refreshToken: "r1", accessExpiresInSeconds: 900)

    @Test("a 401 to the current token ends the session once")
    func refused() async throws {
        let session = SessionStore(vault: InMemoryVault()) { _ in .rejected }
        let endings = Endings()
        await session.setSessionEndedHandler { await endings.record() }
        try await session.signIn(tokens, email: "dinda@email.com")
        await session.sessionRefused("a1")
        #expect(!session.hasSession && session.accountEmail == nil)
        await session.sessionRefused("a1")
        #expect(await endings.events == ["ended"])
    }

    @Test("a 401 to a token already replaced leaves the session as it is")
    func staleToken() async throws {
        let session = SessionStore(vault: InMemoryVault()) { _ in .rejected }
        let endings = Endings()
        await session.setSessionEndedHandler { await endings.record() }
        try await session.signIn(tokens, email: "dinda@email.com")
        await session.sessionRefused("a0")
        #expect(session.hasSession)
        #expect(await endings.events.isEmpty)
    }
}
