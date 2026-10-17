import APIClient
import Domain
import Foundation
import Testing

@testable import Features

/**
 A session the server has revoked, through the real wiring: `AuthMiddleware` on the protected
 client, `SessionRefresh` on the public one, and the root listening for the session's end.
 */
@MainActor
@Suite("Revoked session")
struct RevokedSessionTests {
    /** A signed-in root whose API answers `GET /api/me` with 401 and the refresh with `refresh`. */
    private func revoked(refresh: RoutedTransport.Reply) async throws -> (RootModel, KiraAPI) {
        let replies = ["GET /api/me": problem("AUTH_UNAUTHENTICATED", status: 401), "POST /api/auth/refresh": refresh]
        let (publicAPI, _) = KiraAPI.routed(replies)
        let vault = InMemoryVault()
        let session = SessionStore(vault: vault) { try await SessionRefresh.refresh($0, with: publicAPI) }
        try await session.signIn(rootTokens, email: "dinda@email.com")
        let api = KiraAPI(
            serverURL: URL(string: "https://api.test") ?? URL(filePath: "/"),
            middlewares: [AuthMiddleware(tokens: session)], transport: RoutedTransport(replies))
        let root = RootModel(session: session, lock: AppLockModel(pins: PinStore(vault: vault), vault: vault)) {
            nil
        } sleep: { _ in
        }
        await root.start()
        #expect(root.stage == .main)
        return (root, api)
    }

    @Test(
        "a refresh the API refuses lands on Masuk, with or without a problem body",
        arguments: [
            problem("AUTH_REFRESH_INVALID", status: 401),
            RoutedTransport.Reply(status: 401, body: "<html>401</html>", contentType: "text/html"),
            RoutedTransport.Reply(status: 401, body: nil),
        ])
    func refusedRefresh(refresh: RoutedTransport.Reply) async throws {
        let (root, api) = try await revoked(refresh: refresh)
        _ = try? await api.getMe()
        #expect(!root.session.hasSession)
        #expect(root.stage == .onboarding)
        #expect(root.onboardingStart == .signIn)
    }

    @Test("a 401 to the token just renewed lands on Masuk too")
    func refusedAfterRenewal() async throws {
        let (root, api) = try await revoked(refresh: ok("{\(tokensJSON)}"))
        _ = try? await api.getMe()
        #expect(!root.session.hasSession)
        #expect(root.stage == .onboarding && root.onboardingStart == .signIn)
    }

    @Test("a refresh the API cannot answer keeps the session for the next try")
    func unreachableRefresh() async throws {
        let (root, api) = try await revoked(refresh: RoutedTransport.Reply(status: 503, body: nil))
        _ = try? await api.getMe()
        #expect(root.session.hasSession)
        #expect(root.stage == .main)
    }
}
