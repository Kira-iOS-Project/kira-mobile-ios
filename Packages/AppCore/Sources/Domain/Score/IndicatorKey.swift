/** The six Kira Score indicators: the backend's `INDICATOR` values. */
package enum IndicatorKey: String, CaseIterable, Codable, Sendable {
    case emergencyFund = "emergency_fund"
    case savingsRatio = "savings_ratio"
    case instalmentRatio = "instalment_ratio"
    case consumerDebt = "consumer_debt"
    case debtToAsset = "debt_to_asset"
    case protection = "protection_cover"
}
