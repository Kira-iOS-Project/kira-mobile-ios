import SwiftUI

/** "Punya Produk?" at the foot of Etalase: opens Kirim Produk (KOM-08). */
struct SubmitProductCard: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: KiraSpacing.space3) {
                KiraIcon(.send, size: 22)
                    .foregroundStyle(.pandan)
                    .frame(width: KiraSize.tap, height: KiraSize.tap)
                    .kiraCard(border: .pandanLine, cornerRadius: KiraRadius.small)
                VStack(alignment: .leading, spacing: 2) {
                    Text("marketplace.submit.title").font(.callout.weight(.semibold)).kiraLineHeight(21, size: 16)
                        .foregroundStyle(.ink)
                    Text("marketplace.submit.body").font(.footnote).kiraLineHeight(18, size: 13)
                        .foregroundStyle(.inkMuted)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                KiraIcon(.chevronRight, size: 20).foregroundStyle(.inkMuted)
            }
            .padding(14)
            .kiraCard(.pandanSoft, border: .pandanLine)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("marketplace.submit.label"))
        .accessibilityAddTraits(.isButton)
    }
}
