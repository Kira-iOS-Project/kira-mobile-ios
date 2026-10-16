/** The sign-in calls: what each sends, what it returns, and every problem it can throw. */
import Foundation
import HTTPTypes
import Testing

@testable import APIClient

private struct EmailBody: Decodable { let email: String }
private struct VerifyBody: Decodable { let email: String, code: String }
private struct RefreshBody: Decodable { let refreshToken: String }

private let tokensJSON = #"{"accessToken":"a","refreshToken":"r","accessExpiresInSeconds":900"#

@Suite("AuthAPI")
struct AuthAPITests {
    @Test("requests a code for the address")
    func requestsCode() async throws {
        let (api, transport) = KiraAPI.canned(
            status: 202, json: #"{"expiresInSeconds":600,"resendAfterSeconds":60}"#)
        let sent = try await api.requestSignInCode(email: "dinda@email.com")
        #expect(sent.resendAfterSeconds == 60)
        let request = try #require(await transport.request)
        #expect(request.method == .post && request.path.hasSuffix("auth/code"))
        #expect(try request.decoded(EmailBody.self).email == "dinda@email.com")
    }

    @Test("verifies the code and reads the session")
    func verifiesCode() async throws {
        let (api, transport) = KiraAPI.canned(json: tokensJSON + #","needsOnboarding":true}"#)
        let signedIn = try await api.verifySignInCode(email: "dinda@email.com", code: "381427")
        #expect(signedIn.needsOnboarding)
        #expect(signedIn.tokens.accessToken == "a" && signedIn.tokens.accessExpiresInSeconds == 900)
        let body = try #require(await transport.request).decoded(VerifyBody.self)
        #expect(body.code == "381427")
    }

    @Test("refreshes the pair")
    func refreshes() async throws {
        let (api, transport) = KiraAPI.canned(json: tokensJSON + "}")
        let tokens = try await api.refreshSession(refreshToken: "old")
        #expect(tokens.refreshToken == "r")
        #expect(try #require(await transport.request).decoded(RefreshBody.self).refreshToken == "old")
    }

    @Test("signs out")
    func signsOut() async throws {
        let (api, transport) = KiraAPI.canned(status: 204)
        try await api.signOut()
        #expect(try #require(await transport.request).path.hasSuffix("auth/sign-out"))
    }

    @Test("throws every problem the sign-in routes answer")
    func problems() async {
        await expectProblems([422, 429, 503]) { _ = try await $0.requestSignInCode(email: "a@b.co") }
        await expectProblems([400, 422, 429]) { _ = try await $0.verifySignInCode(email: "a@b.co", code: "1") }
        await expectProblems([401, 422]) { _ = try await $0.refreshSession(refreshToken: "r") }
        await expectProblems([401]) { try await $0.signOut() }
    }
}
