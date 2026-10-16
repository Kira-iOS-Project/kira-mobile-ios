/** What `POST /auth/code` answers once the email with the code is on its way. */
package struct CodeDelivery: Hashable, Sendable {
    /** How long before another code may be asked for: 60 seconds. */
    package let resendAfterSeconds: Int

    /** A delivery that may be asked for again after `resendAfterSeconds`. */
    package init(resendAfterSeconds: Int) {
        self.resendAfterSeconds = resendAfterSeconds
    }
}
