/** The six Kira Score indicators: the backend's `INDICATOR` values. */
package enum IndicatorKey: String, CaseIterable, Codable, Sendable {
    /** Dana Darurat, in the Tabung group. */
    case emergencyFund = "emergency_fund"
    /** Rasio Menabung, in the Tabung group. */
    case savingsRatio = "savings_ratio"
    /** Rasio Cicilan, in the Utang group. */
    case instalmentRatio = "instalment_ratio"
    /** Utang Konsumtif, in the Utang group. */
    case consumerDebt = "consumer_debt"
    /** Utang terhadap Aset, in the Utang group. */
    case debtToAsset = "debt_to_asset"
    /** Proteksi, the Lindungi group. */
    case protection = "protection_cover"
}
