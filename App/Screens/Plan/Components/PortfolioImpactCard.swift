/**
 "Dampak ke Kira Score" (board Portofolio): the growing plant, how the assets count in Utang
 terhadap Aset with its percentage, and the indicator's points with their band. It opens Kira Score.
 */
import Domain
import Features
import SwiftUI

struct PortfolioImpactCard: View {
    let impact: DebtToAssetImpact
    let onOpen: (AppRoute) -> Void

    var body: some View {
        Button {
            onOpen(.score)
        } label: {
            HStack(spacing: 12) {
                KiraIllustration(.growing, size: 56)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay { RoundedRectangle(cornerRadius: 16, style: .continuous).strokeBorder(.hairline) }
                    .frame(maxHeight: .infinity, alignment: .top)
                VStack(alignment: .leading, spacing: 2) {
                    Text("portfolio.impact.title").font(.headline).kiraLineHeight(22, size: 17).foregroundStyle(.ink)
                    Text("portfolio.impact.body \(impact.percent)")
                        .font(.subheadline).kiraLineHeight(20, size: 15).foregroundStyle(.inkMuted)
                    HStack(spacing: 8) {
                        Text(impact.points, format: .number)
                            .font(KiraFont.display(17, .heavy, relativeTo: .headline)).monospacedDigit()
                            .foregroundStyle(.ink)
                        KiraBandPill(impact.band, size: .small)
                    }
                    .padding(.top, 6)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                KiraIcon(.chevronRight, size: 20).foregroundStyle(.inkMuted)
            }
            .padding(EdgeInsets(top: 14, leading: 12, bottom: 14, trailing: 14))
            .kiraCard(.surfaceRaised, cornerRadius: KiraRadius.large)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
    }
}
