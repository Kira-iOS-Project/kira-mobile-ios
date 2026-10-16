/**
 The top card of Detail Produk: illustration and badge, title and description, the price ("Gratis"
 for a free product, never Rp0,00) beside the product's size or date, and the seller.
 */
import Domain
import SwiftUI

struct ProductSummaryCard: View {
    let product: Product

    private var summary: ProductSummary { product.summary }

    var body: some View {
        VStack(alignment: .leading, spacing: KiraSpacing.space3) {
            HStack(alignment: .top, spacing: KiraSpacing.space3) {
                KiraIllustration(summary.art.illustration, size: 72)
                Spacer(minLength: 0)
                KiraTag("marketplace.badge \(summary.sellerBadge)", tone: .pandan, icon: .shield)
            }
            VStack(alignment: .leading, spacing: 6) {
                Text(summary.title)
                    .font(KiraFont.display(24, .heavy, relativeTo: .title2))
                    .kiraLineHeight(30, size: 24, natural: 1.26, relativeTo: .title2)
                    .tracking(-0.48)
                    .foregroundStyle(.ink)
                    .accessibilityAddTraits(.isHeader)
                Text(product.description).font(.subheadline).kiraLineHeight(21, size: 15).foregroundStyle(.inkMuted)
            }
            HStack(alignment: .bottom, spacing: KiraSpacing.space3) {
                price
                Spacer(minLength: 0)
                HStack(spacing: 6) {
                    KiraIcon(.info, size: 16)
                    Text(product.meta).multilineTextAlignment(.trailing)
                }
                .font(.footnote).kiraLineHeight(18, size: 13).foregroundStyle(.inkMuted)
                .padding(.bottom, 3)
            }
            KiraListRow(Text(summary.sellerName), leading: .initials(summary.sellerInitials, summary.kind.avatarTone))
                .subtitle(Text(product.sellerRole))
                .overlay(alignment: .top) { Rectangle().fill(.line).frame(height: 1) }
        }
        .padding(EdgeInsets(top: 18, leading: 20, bottom: 6, trailing: 20))
        .kiraCard()
    }

    private var price: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("product.price").font(.footnote.weight(.semibold)).kiraLineHeight(18, size: 13).foregroundStyle(.inkMuted)
            if let price = summary.price, !summary.isFree {
                KiraAmount(price.rupiah, size: .medium)
            } else {
                Text("marketplace.free")
                    .font(KiraFont.display(22, .heavy, relativeTo: .title2))
                    .kiraLineHeight(28, size: 22, natural: 1.26, relativeTo: .title2)
                    .foregroundStyle(.healthy)
            }
        }
    }
}

/** "Yang Kamu Pelajari" and its points, each behind a check, in one card. */
struct ProductContentsList: View {
    let product: Product

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            KiraSectionTitle("product.contents \(product.contentsTitle)")
            KiraRowStack {
                ForEach(product.contents, id: \.self) { point in
                    HStack(alignment: .top, spacing: KiraSpacing.space3) {
                        KiraIcon(.check, size: 15, weight: .bold)
                            .foregroundStyle(.pandan)
                            .frame(width: 26, height: 26)
                            .background(.pandanSoft, in: Circle())
                            .overlay { Circle().strokeBorder(.pandanLine, lineWidth: 1) }
                            .accessibilityHidden(true)
                        Text(point).font(.subheadline).kiraLineHeight(21, size: 15).foregroundStyle(.ink)
                            .padding(.top, 2)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.vertical, 11)
                    .kiraRowSeparator()
                }
            }
            .padding(.horizontal, KiraSpacing.space4)
            .padding(.vertical, KiraSpacing.space1)
            .kiraCard()
        }
    }
}
