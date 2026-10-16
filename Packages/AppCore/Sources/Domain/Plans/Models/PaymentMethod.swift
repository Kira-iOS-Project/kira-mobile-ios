/** How a subscription or a Traktir Kira is paid (simulated for now): the backend's `PAYMENT_METHOD` values. */
package enum PaymentMethod: String, CaseIterable, Codable, Sendable {
    /** QRIS, paid from a bank or e-wallet app. */
    case qris
    /** Billed through the person's Apple account. */
    case appStore = "app_store"
}
