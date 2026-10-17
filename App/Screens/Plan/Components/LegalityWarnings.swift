/**
 Cek Legalitas's Tanda Bahaya (board CekLegalitas): four signs of a scam, each with the alert on a
 vulnerable tile, in one hairline card, then the sentence for someone who has already transferred.
 */
import SwiftUI

struct LegalityWarnings: View {
    private let signs: [(LocalizedStringResource, LocalizedStringResource)] = [
        ("legality.sign.guaranteed", "legality.sign.guaranteed.detail"),
        ("legality.sign.personalAccount", "legality.sign.personalAccount.detail"),
        ("legality.sign.today", "legality.sign.today.detail"),
        ("legality.sign.noLicence", "legality.sign.noLicence.detail"),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            KiraSectionTitle("legality.signs")
            KiraRowStack {
                ForEach(signs.indices, id: \.self) { index in
                    sign(signs[index].0, detail: signs[index].1).kiraRowSeparator()
                }
            }
            .padding(.horizontal, KiraSpacing.space4)
            .kiraCard()
            Text("legality.transferred").font(.footnote).kiraLineHeight(18, size: 13).foregroundStyle(.inkMuted)
                .padding(.horizontal, KiraSpacing.space1)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func sign(_ title: LocalizedStringResource, detail: LocalizedStringResource) -> some View {
        HStack(alignment: .top, spacing: 12) {
            KiraIcon(.alert, size: 20).foregroundStyle(.vulnerable)
                .frame(width: 38, height: 38)
                .kiraCard(.vulnerableSoft, border: .vulnerableLine, cornerRadius: KiraRadius.small)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.callout.weight(.semibold)).kiraLineHeight(21, size: 16).foregroundStyle(.ink)
                Text(detail).font(.footnote).kiraLineHeight(18, size: 13).foregroundStyle(.inkMuted)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 14)
        .accessibilityElement(children: .combine)
    }
}
