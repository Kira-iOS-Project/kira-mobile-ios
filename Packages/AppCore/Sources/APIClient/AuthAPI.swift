/** Sign-in with an email and a six-digit code, and the session's token pair. */
extension KiraAPI {
    /** Emails a sign-in code (`POST /api/auth/code`). 429 `AUTH_CODE_RATE_LIMITED` when too soon. */
    package func requestSignInCode(email: String) async throws -> SignInCodeSent {
        try await client.requestSignInCode(body: .json(.init(email: email))).sent()
    }

    /** Trades the code for a session (`POST /api/auth/verify`), creating the account if new. */
    package func verifySignInCode(email: String, code: String) async throws -> SignedIn {
        try await client.verifySignInCode(body: .json(.init(email: email, code: code))).signedIn()
    }

    /** Trades a refresh token for a new pair (`POST /api/auth/refresh`); the old one stops working. */
    package func refreshSession(refreshToken: String) async throws -> SessionTokens {
        try await client.refreshSession(body: .json(.init(refreshToken: refreshToken))).tokens()
    }

    /** Ends this session (`POST /api/auth/sign-out`). */
    package func signOut() async throws {
        try await client.signOut().done()
    }
}

extension Operations.RequestSignInCode.Output {
    func sent() throws -> SignInCodeSent {
        switch self {
        case .accepted(let response): return SignInCodeSent(try response.body.json)
        case .unprocessableContent(let response): throw try response.body.applicationProblemJson
        case .tooManyRequests(let response): throw try response.body.applicationProblemJson
        case .serviceUnavailable(let response): throw try response.body.applicationProblemJson
        case .undocumented: throw AppProblem()
        }
    }
}

extension Operations.VerifySignInCode.Output {
    func signedIn() throws -> SignedIn {
        switch self {
        case .ok(let response): return SignedIn(try response.body.json)
        case .badRequest(let response): throw try response.body.applicationProblemJson
        case .unprocessableContent(let response): throw try response.body.applicationProblemJson
        case .tooManyRequests(let response): throw try response.body.applicationProblemJson
        case .undocumented: throw AppProblem()
        }
    }
}

extension Operations.RefreshSession.Output {
    func tokens() throws -> SessionTokens {
        switch self {
        case .ok(let response): return SessionTokens(try response.body.json)
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .unprocessableContent(let response): throw try response.body.applicationProblemJson
        case .undocumented: throw AppProblem()
        }
    }
}

extension Operations.SignOut.Output {
    func done() throws {
        switch self {
        case .noContent: return
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .undocumented: throw AppProblem()
        }
    }
}
