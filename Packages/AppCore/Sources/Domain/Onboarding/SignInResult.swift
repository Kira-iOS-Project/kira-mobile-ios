/**
 What a correct code leads to. The service keeps the tokens (the refresh token in the Keychain,
 AGENTS.md Rule 13); screens only learn whether the account still needs onboarding.
 */
package struct SignInResult: Hashable, Sendable {
    /** True for a new account (consent, focus, health check); false goes straight to Beranda. */
    package let needsOnboarding: Bool

    /** A result for an account that does or does not still need onboarding. */
    package init(needsOnboarding: Bool) {
        self.needsOnboarding = needsOnboarding
    }
}
