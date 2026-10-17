/**
 The asset classes Pelajari Dulu lists (REN-07), lowest risk first, each with its own module
 (REN-08). Kira teaches classes only: never a product, a ticker, a coin or an issuer.
 */
package enum RiskAssetClass: String, CaseIterable, Hashable, Sendable {
    /** Reksa Dana Pasar Uang. */
    case moneyMarketFund
    /** SBN, the government's securities. */
    case governmentBonds
    /** Deposito. */
    case deposits
    /** Emas. */
    case gold
    /** Saham. */
    case stocks
    /** Kripto. */
    case crypto

    /** The risk label its row and module show. */
    package var risk: AssetRisk {
        switch self {
        case .moneyMarketFund, .governmentBonds, .deposits: .low
        case .gold: .medium
        case .stocks: .high
        case .crypto: .veryHigh
        }
    }
}

/** A risk label: Rendah, Sedang, Tinggi, Sangat Tinggi. */
package enum AssetRisk: Int, CaseIterable, Hashable, Sendable {
    /** Risiko Rendah. */
    case low
    /** Risiko Sedang. */
    case medium
    /** Risiko Tinggi. */
    case high
    /** Risiko Sangat Tinggi. */
    case veryHigh
}
