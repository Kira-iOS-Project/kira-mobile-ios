import Foundation
import HTTPTypes
import OpenAPIRuntime

/**
 Signs every request of the generated client with the bearer token, except the operations that
 need none (requesting and verifying the sign-in code, refreshing the session). When the API
 answers 401, the middleware asks for a renewed token once and sends the request once more; a
 second 401 reaches the screen as it is. A body that can be read only once is never sent twice.
 */
package struct AuthMiddleware: ClientMiddleware {
    /** The operations (operationId) that the API serves without a bearer token. */
    package static let publicOperations: Set<String> = [
        "requestSignInCode", "verifySignInCode", "refreshSession", "getHealth",
    ]

    private let tokens: any BearerTokenSource
    private let publicOperations: Set<String>

    /** A middleware that signs requests with the tokens of `tokens`. */
    package init(tokens: any BearerTokenSource, publicOperations: Set<String> = Self.publicOperations) {
        self.tokens = tokens
        self.publicOperations = publicOperations
    }

    /** Adds the bearer token, and on 401 retries once with a renewed one. */
    package func intercept(
        _ request: HTTPRequest, body: HTTPBody?, baseURL: URL, operationID: String,
        next: @concurrent @Sendable (HTTPRequest, HTTPBody?, URL) async throws -> (HTTPResponse, HTTPBody?)
    ) async throws -> (HTTPResponse, HTTPBody?) {
        guard !publicOperations.contains(operationID), let token = await tokens.bearerToken() else {
            return try await next(request, body, baseURL)
        }
        let (response, responseBody) = try await next(Self.signed(request, with: token), body, baseURL)
        guard response.status == .unauthorized, body?.iterationBehavior != .single,
            let renewed = await tokens.renewedBearerToken(replacing: token)
        else { return (response, responseBody) }
        return try await next(Self.signed(request, with: renewed), body, baseURL)
    }

    /** `request` with `Authorization: Bearer <token>`, replacing any it had. */
    private static func signed(_ request: HTTPRequest, with token: String) -> HTTPRequest {
        var signed = request
        signed.headerFields[.authorization] = "Bearer \(token)"
        return signed
    }
}
