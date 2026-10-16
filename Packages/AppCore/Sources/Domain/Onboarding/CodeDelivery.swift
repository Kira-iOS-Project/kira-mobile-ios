/** What `POST /auth/code` answers once the email with the code is on its way. */
package struct CodeDelivery: Hashable, Sendable {
    /** How long the code works: 600 seconds. */
    package let expiresInSeconds: Int
    /** How long before another code may be asked for: 60 seconds. */
    package let resendAfterSeconds: Int

    /** A delivery with the server's two durations. */
    package init(expiresInSeconds: Int, resendAfterSeconds: Int) {
        self.expiresInSeconds = expiresInSeconds
        self.resendAfterSeconds = resendAfterSeconds
    }
}
