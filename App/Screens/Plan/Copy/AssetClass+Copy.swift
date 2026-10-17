/**
 Pelajari Dulu's rows (HasilRisiko): each asset class's name, line, category tile and risk tag, as
 the board draws them. Risk tags: Rendah healthy, Sedang turmeric, Tinggi and Sangat Tinggi
 vulnerable; never red.
 */
import Domain
import Foundation

extension AssetClass {
    /** The class's name. */
    var title: LocalizedStringResource {
        switch self {
        case .moneyMarketFund: "plan.asset.moneyMarketFund"
        case .governmentBonds: "plan.asset.governmentBonds"
        case .deposits: "plan.asset.deposits"
        case .gold: "plan.asset.gold"
        case .stocks: "plan.asset.stocks"
        case .crypto: "plan.asset.crypto"
        }
    }

    /** The line under the name. */
    var subtitle: LocalizedStringResource {
        switch self {
        case .moneyMarketFund: "plan.asset.moneyMarketFund.subtitle"
        case .governmentBonds: "plan.asset.governmentBonds.subtitle"
        case .deposits: "plan.asset.deposits.subtitle"
        case .gold: "plan.asset.gold.subtitle"
        case .stocks: "plan.asset.stocks.subtitle"
        case .crypto: "plan.asset.crypto.subtitle"
        }
    }

    /** The category tile. */
    var tile: KiraCategory {
        switch self {
        case .moneyMarketFund: .mutualFunds
        case .governmentBonds: .governmentBonds
        case .deposits: .bank
        case .gold: .gold
        case .stocks: .stocks
        case .crypto: .crypto
        }
    }
}

extension AssetRisk {
    /** Risiko Rendah, Sedang, Tinggi, Sangat Tinggi. */
    var title: LocalizedStringResource {
        switch self {
        case .low: "plan.asset.risk.low"
        case .medium: "plan.asset.risk.medium"
        case .high: "plan.asset.risk.high"
        case .veryHigh: "plan.asset.risk.veryHigh"
        }
    }

    /** The tag's tone. */
    var tone: KiraTag.Tone {
        switch self {
        case .low: .healthy
        case .medium: .turmeric
        case .high, .veryHigh: .vulnerable
        }
    }
}
