/**
 The words of each asset-class module (REN-08), by class and part, in the String Catalog. The board
 ModulKelasAset draws Reksa Dana Pasar Uang part 2; the other five classes and parts 3 and 4 are
 content not on a board, written as plain education in the board's structure (what it is, its
 risk, when it can be cashed out, the shortest time it suits, who oversees or guarantees it), with
 no product, ticker, coin or issuer and nothing that recommends. Owner review pending.
 */
import Domain
import SwiftUI

/** One titled section of a part: a paragraph or a checked list, and the Cek Legalitas link under it. */
struct AssetModuleSection: Identifiable {
    let title: LocalizedStringResource
    var body: LocalizedStringResource?
    var items: [LocalizedStringResource] = []
    var checksLegality = false

    var id: String { title.key }
}

extension AssetClass {
    /** The module's heading, the name Hasil Risiko's row shows. */
    var moduleTitle: LocalizedStringResource {
        switch self {
        case .moneyMarketFund: "plan.module.class.moneyMarketFund"
        case .governmentBonds: "plan.module.class.governmentBonds"
        case .deposits: "plan.module.class.deposits"
        case .gold: "plan.module.class.gold"
        case .stocks: "plan.module.class.stocks"
        case .crypto: "plan.module.class.crypto"
        }
    }

    /** The class's illustrated tile; deposits use the bank tile. */
    var moduleCategory: KiraCategory {
        switch self {
        case .moneyMarketFund: .mutualFunds
        case .governmentBonds: .governmentBonds
        case .deposits: .bank
        case .gold: .gold
        case .stocks: .stocks
        case .crypto: .crypto
        }
    }

    /** The sections of `part`, in the board's order. */
    func moduleSections(_ part: AssetModulePart) -> [AssetModuleSection] {
        switch part {
        case .basics:
            [
                AssetModuleSection(title: "plan.module.section.whatItIs", body: text("what")),
                AssetModuleSection(title: "plan.module.section.risk", body: text("risk")),
                AssetModuleSection(title: "plan.module.section.fitsFor", items: [text("fit1"), text("fit2")]),
                AssetModuleSection(title: "plan.module.section.howToCheck", body: text("check"), checksLegality: true),
            ]
        case .holding:
            [
                AssetModuleSection(title: "plan.module.section.cashOut", body: text("cashOut")),
                AssetModuleSection(title: "plan.module.section.horizon", body: text("horizon")),
                AssetModuleSection(title: "plan.module.section.returns", body: text("returns")),
            ]
        case .oversight:
            [
                AssetModuleSection(title: "plan.module.section.oversight", body: text("oversight"), checksLegality: true),
                AssetModuleSection(title: "plan.module.section.guarantee", body: text("guarantee")),
                AssetModuleSection(title: "plan.module.section.beforeStarting", items: [text("before1"), text("before2")]),
            ]
        }
    }

    /** `plan.module.<class>.<field>`, the class's own sentence for a section. */
    private func text(_ field: String) -> LocalizedStringResource {
        LocalizedStringResource(String.LocalizationValue("plan.module.\(rawValue).\(field)"))
    }
}

extension AssetRisk {
    /** The risk Tag: Rendah green, Sedang turmeric, Tinggi and Sangat Tinggi red, as Hasil Risiko draws them. */
    var moduleTag: (title: LocalizedStringResource, tone: KiraTag.Tone) {
        switch self {
        case .low: ("plan.module.risk.low", .healthy)
        case .medium: ("plan.module.risk.medium", .turmeric)
        case .high: ("plan.module.risk.high", .vulnerable)
        case .veryHigh: ("plan.module.risk.veryHigh", .vulnerable)
        }
    }
}
