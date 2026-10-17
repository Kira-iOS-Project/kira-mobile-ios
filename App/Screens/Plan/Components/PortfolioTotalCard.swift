/**
 Portofolio's "Total aset investasi" card (board Portofolio): the overline with the eye that hides
 every amount, the large total, the day it was last updated by hand, and the composition bar by
 class with its legend. The bar is one image VoiceOver reads as "Komposisi: Reksa Dana 38%, …"; the
 legend under it repeats it for the eye only.
 */
import Domain
import Features
import SwiftUI

struct PortfolioTotalCard: View {
    let model: PortfolioModel
    let portfolio: Portfolio

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("portfolio.total.title").kiraFont(.overline).foregroundStyle(.inkMuted)
                Spacer(minLength: KiraSpacing.space2)
                KiraIconButton(
                    model.isMasked ? .eyeOff : .eye, label: model.isMasked ? "portfolio.mask.show" : "portfolio.mask.hide"
                ) { model.toggleMasked() }
                .accessibilityAddTraits(model.isMasked ? .isSelected : [])
                .padding(.trailing, -10)
            }
            .frame(minHeight: 24)
            KiraAmount(Decimal(portfolio.total), size: .large).masked(model.isMasked)
            if let updatedOn = portfolio.updatedOn {
                Label {
                    Text("portfolio.updated \(updatedOn.date.formatted(.kiraDate))")
                } icon: {
                    KiraIcon(.pencil, size: 14)
                }
                .font(.footnote.weight(.medium)).kiraLineHeight(18, size: 13).foregroundStyle(.inkMuted)
            }
            if !model.classShares.isEmpty { composition }
        }
        .padding(EdgeInsets(top: 18, leading: 18, bottom: 20, trailing: 18))
        .frame(maxWidth: .infinity, alignment: .leading)
        .kiraCard(.surfaceRaised, cornerRadius: KiraRadius.large)
    }

    private var composition: some View {
        VStack(alignment: .leading, spacing: 6) {
            GeometryReader { proxy in
                let gaps = CGFloat(model.classShares.count - 1) * 3
                HStack(spacing: 3) {
                    ForEach(model.classShares, id: \.assetClass) { share in
                        RoundedRectangle(cornerRadius: 3).fill(share.assetClass.paint)
                            .frame(width: (proxy.size.width - gaps) * CGFloat(share.percent) / 100)
                    }
                }
            }
            .frame(height: 12)
            .clipShape(Capsule())
            .accessibilityElement()
            .accessibilityAddTraits(.isImage)
            .accessibilityLabel(model.classShares.compositionLabel)
            .padding(.top, 14)
            legend
        }
    }

    private var legend: some View {
        KiraFlowRow(spacing: 14) {
            ForEach(model.classShares, id: \.assetClass) { share in
                HStack(spacing: 6) {
                    Circle().fill(share.assetClass.paint).frame(width: 8, height: 8)
                    Text(share.assetClass.title)
                }
            }
        }
        .font(.caption.weight(.semibold)).kiraLineHeight(16, size: 12).foregroundStyle(.inkMuted)
        .padding(.top, 6)
        .accessibilityHidden(true)
    }
}
