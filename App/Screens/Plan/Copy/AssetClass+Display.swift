/**
 How Portofolio and Tambah Aset draw an asset class: its name, its illustrated tile, and its paint
 in the composition bar. The board paints Reksa Dana sky, SBN green and Emas turmeric; the other
 four take the remaining illustration paints, so no two classes share one.
 */
import Domain
import SwiftUI

extension AssetClass {
    /** The class's name: "Deposito", "Reksa Dana", "SBN", "Emas", "Saham", "Kripto", "Lainnya". */
    var title: LocalizedStringResource {
        switch self {
        case .deposit: "asset.class.deposit"
        case .mutualFund: "asset.class.mutualFund"
        case .governmentBond: "asset.class.governmentBond"
        case .gold: "asset.class.gold"
        case .stock: "asset.class.stock"
        case .crypto: "asset.class.crypto"
        case .other: "asset.class.other"
        }
    }

    /** The tile of the grid and of the asset's row. */
    var tile: KiraCategory {
        switch self {
        case .deposit: .bank
        case .mutualFund: .mutualFunds
        case .governmentBond: .governmentBonds
        case .gold: .gold
        case .stock: .stocks
        case .crypto: .crypto
        case .other: .other
        }
    }

    /** Its paint in the composition bar, its legend and its row. */
    var paint: Color {
        switch self {
        case .deposit: .artSkyDark
        case .mutualFund: .artSky
        case .governmentBond: .artGreen
        case .gold: .artTurmeric
        case .stock: .artGreenDark
        case .crypto: .artPeach
        case .other: .artSoil
        }
    }
}

extension [ClassShare] {
    /** The bar's label: "Komposisi: Reksa Dana 38%, SBN 32%, Emas 30%". */
    var compositionLabel: Text {
        let parts = map { Text("portfolio.composition.part \(Text($0.assetClass.title)) \($0.percent)") }
        guard var joined = parts.first else { return Text("portfolio.total.title") }
        for part in parts.dropFirst() { joined = Text("portfolio.composition.join \(joined) \(part)") }
        return Text("portfolio.composition \(joined)")
    }
}
