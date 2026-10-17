/**
 One product of Etalase (KOM-06): its illustration, kind, title, seller, the team's badge, and the
 price in full or "Gratis" (never Rp0,00), as one button named by its whole sentence.
 */
import Domain
import SwiftUI

struct ProductCard: View {
    let product: ProductSummary
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            /** The chevron centred on the card's height, as the board's align-self: center. */
            HStack(spacing: 14) {
                HStack(alignment: .top, spacing: 14) {
                    KiraIllustration(product.art.illustration, size: 64)
                        .clipShape(RoundedRectangle(cornerRadius: KiraRadius.medium, style: .continuous))
                        .hairline(cornerRadius: KiraRadius.medium)
                    details
                }
                KiraIcon(.chevronRight, size: 20).foregroundStyle(.inkMuted)
            }
            .padding(KiraSpacing.space4)
            .kiraCard()
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(label)
        .accessibilityAddTraits(.isButton)
    }

    private var details: some View {
        VStack(alignment: .leading, spacing: KiraSpacing.space1) {
            Text(product.kind.title).kiraFont(.overline).foregroundStyle(.inkMuted)
            Text(product.title).font(.headline).kiraLineHeight(22, size: 17).foregroundStyle(.ink)
            HStack(spacing: 6) {
                /** Decorative: the card's label already names the seller. */
                KiraAvatar(product.sellerInitials, size: 26, tone: product.kind.avatarTone)
                    .accessibilityHidden(true)
                Text(product.sellerName).font(.footnote).kiraLineHeight(18, size: 13).foregroundStyle(.inkMuted)
            }
            .padding(.top, 2)
            KiraFlowRow(spacing: 6) {
                KiraTag("marketplace.badge \(product.sellerBadge)", tone: .pandan, icon: .shield)
                if product.isFree { KiraTag("marketplace.free", tone: .healthy) }
            }
            .padding(.top, 6)
            if let price = product.price, !product.isFree {
                KiraAmount(price.rupiah, size: .small).padding(.top, 6)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    /** "Kelas Budgeting Gaji Pertama oleh Raka Aditya, Rp149.000,00", or "…, gratis". */
    private var label: Text {
        guard let price = product.price, !product.isFree else {
            return Text("marketplace.card.free \(product.title) \(product.sellerName)")
        }
        return Text("marketplace.card.paid \(product.title) \(product.sellerName) \(price.rupiah, format: .rupiah)")
    }
}
