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
        case .moneyMarketFund: "plan.risk.asset.moneyMarketFund"
        case .governmentBonds: "plan.risk.asset.governmentBonds"
        case .deposits: "plan.risk.asset.deposits"
        case .gold: "plan.risk.asset.gold"
        case .stocks: "plan.risk.asset.stocks"
        case .crypto: "plan.risk.asset.crypto"
        }
    }

    /** The line under the name. */
    var subtitle: LocalizedStringResource {
        switch self {
        case .moneyMarketFund: "plan.risk.asset.moneyMarketFund.subtitle"
        case .governmentBonds: "plan.risk.asset.governmentBonds.subtitle"
        case .deposits: "plan.risk.asset.deposits.subtitle"
        case .gold: "plan.risk.asset.gold.subtitle"
        case .stocks: "plan.risk.asset.stocks.subtitle"
        case .crypto: "plan.risk.asset.crypto.subtitle"
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
        case .low: "plan.risk.asset.risk.low"
        case .medium: "plan.risk.asset.risk.medium"
        case .high: "plan.risk.asset.risk.high"
        case .veryHigh: "plan.risk.asset.risk.veryHigh"
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
