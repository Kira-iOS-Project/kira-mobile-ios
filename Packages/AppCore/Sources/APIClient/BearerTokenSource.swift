/**
 Where the client's middleware gets the bearer token (AGENTS.md Rule 13). The session in Features
 implements it: the token lives in memory and is minted again from the Keychain's refresh token.
 */

/** The bearer token of the signed-in person, and a fresh one when the API refuses it. */
package protocol BearerTokenSource: Sendable {
    /** The current bearer token, renewed first when it has expired; nil when signed out. */
    func bearerToken() async -> String?

    /**
     A token to replace `rejected`, which the API answered with 401: the one another request
     renewed meanwhile, or a new one from the refresh token. Nil when the session has ended.
     */
    func renewedBearerToken(replacing rejected: String) async -> String?
}
