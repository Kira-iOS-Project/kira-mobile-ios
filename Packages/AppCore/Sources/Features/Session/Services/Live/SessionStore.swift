import APIClient
import Foundation

/**
 The signed-in session (AGENTS.md Rule 13): the refresh token and the account's email in the
 vault (the Keychain), the bearer token in memory. It is the client's `BearerTokenSource`: a
 bearer token that has expired, or that the API refused, is minted again from the refresh token,
 once for all the requests waiting on it. When the API refuses the refresh token, the session
 ends and `onSessionEnded` runs.
 */
package actor SessionStore: BearerTokenSource {
    /** Calls `POST /auth/refresh` with a refresh token. */
    package typealias Refresh = @Sendable (String) async throws -> RefreshOutcome

    /** A bearer token is renewed this long before it expires, so it never expires in flight. */
    private static let expiryMargin: TimeInterval = 30

    private let vault: any SecretVault
    private let refresh: Refresh
    private let now: @Sendable () -> Date
    private var access: (token: String, expiresAt: Date)?
    private var renewal: Task<String?, Never>?
    private var onSessionEnded: (@Sendable () async -> Void)?

    /** A session kept in `vault`, renewed with `refresh`, timed by `now`. */
    package init(vault: any SecretVault, now: @escaping @Sendable () -> Date = Date.init, refresh: @escaping Refresh) {
        self.vault = vault
        self.now = now
        self.refresh = refresh
    }

    /** Whether a refresh token is stored: the person signed in on this device and never left. */
    package nonisolated var hasSession: Bool {
        (try? vault.data(for: .refreshToken)) != nil
    }

    /** The signed-in account's email, or nil. */
    package nonisolated var accountEmail: String? {
        guard let data = try? vault.data(for: .accountEmail) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    /** Runs `handler` when the API refuses the refresh token. */
    package func setSessionEndedHandler(_ handler: @escaping @Sendable () async -> Void) {
        onSessionEnded = handler
    }

    /** Starts the session `tokens` opened for `email` (sign-in, or PIN recovery). */
    package func signIn(_ tokens: SessionTokens, email: String) throws {
        try vault.set(Data(email.utf8), for: .accountEmail)
        try store(tokens)
    }

    /** Ends the session on this device: forgets both tokens and the email. */
    package func signOut() {
        renewal?.cancel()
        renewal = nil
        access = nil
        try? vault.remove(.refreshToken)
        try? vault.remove(.accountEmail)
    }

    /** The bearer token, renewed first when it is missing or about to expire. */
    package func bearerToken() async -> String? {
        if let access, access.expiresAt > now() { return access.token }
        guard hasSession else { return nil }
        return await renew()
    }

    /** A token to replace `rejected`: one renewed meanwhile, or a new one. */
    package func renewedBearerToken(replacing rejected: String) async -> String? {
        if let access, access.token != rejected, access.expiresAt > now() { return access.token }
        return await renew()
    }

    /** Renews the bearer token, sharing one call to the API among every caller. */
    private func renew() async -> String? {
        if let renewal { return await renewal.value }
        let task = Task { await performRenewal() }
        renewal = task
        let token = await task.value
        renewal = nil
        return token
    }

    private func performRenewal() async -> String? {
        guard let stored = try? vault.data(for: .refreshToken),
            let refreshToken = String(data: stored, encoding: .utf8)
        else { return nil }
        do {
            switch try await refresh(refreshToken) {
            case .renewed(let tokens):
                try store(tokens)
                return tokens.accessToken
            case .rejected:
                signOut()
                await onSessionEnded?()
                return nil
            }
        } catch {
            /** error ignored: the API is out of reach; the session stays for the next try. */
            return nil
        }
    }

    private func store(_ tokens: SessionTokens) throws {
        try vault.set(Data(tokens.refreshToken.utf8), for: .refreshToken)
        let lifetime = TimeInterval(tokens.accessExpiresInSeconds) - Self.expiryMargin
        access = (tokens.accessToken, now().addingTimeInterval(max(lifetime, 0)))
    }
}
