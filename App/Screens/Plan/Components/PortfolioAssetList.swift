/**
 "Asetmu" (board Portofolio): one row per asset, its tile, its name (the row's title), its class,
 its share of the total in its class's paint, and its value, which the eye hides. Tapping a row
 opens the asset to update its value.
 */
import Domain
import Features
import SwiftUI

struct PortfolioAssetList: View {
    let model: PortfolioModel
    let assets: [Asset]
    let onOpen: (AppRoute) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            KiraSectionTitle("portfolio.assets.title")
            VStack(spacing: 0) {
                ForEach(Array(assets.enumerated()), id: \.element.id) { index, asset in
                    row(asset)
                        .overlay(alignment: .top) { if index > 0 { Rectangle().fill(.hairline).frame(height: 1) } }
                }
            }
            .kiraCard(.surfaceRaised, cornerRadius: KiraRadius.large)
            Text("portfolio.assets.footer")
                .font(.footnote).kiraLineHeight(18, size: 13).foregroundStyle(.inkMuted)
                .padding(.horizontal, 4)
        }
    }

    private func row(_ asset: Asset) -> some View {
        Button {
            onOpen(.editAsset(id: asset.id))
        } label: {
            HStack(spacing: 14) {
                KiraCategoryIcon(asset.assetClass.tile, size: 56)
                VStack(alignment: .leading, spacing: 2) {
                    Text(asset.name).font(.callout.weight(.semibold)).kiraLineHeight(21, size: 16)
                        .foregroundStyle(.ink)
                    Text(asset.assetClass.title).font(.footnote).kiraLineHeight(18, size: 13)
                        .foregroundStyle(.inkMuted)
                    HStack(spacing: 6) {
                        Circle().fill(asset.assetClass.paint).frame(width: 8, height: 8).accessibilityHidden(true)
                        Text("portfolio.asset.share \(model.assetShares[asset.id] ?? 0)")
                    }
                    .font(.footnote.weight(.semibold)).kiraLineHeight(18, size: 13).foregroundStyle(.inkMuted)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                KiraAmount(Decimal(asset.value)).masked(model.isMasked)
            }
            .padding(EdgeInsets(top: 14, leading: 16, bottom: 14, trailing: 16))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityHint(Text("portfolio.asset.hint"))
    }
}
