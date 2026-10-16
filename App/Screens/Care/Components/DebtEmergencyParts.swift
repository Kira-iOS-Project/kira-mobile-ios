/**
 Mode Darurat Utang's header (the title, Gratis Selamanya, the prompt and the stairs) and its
 Beasiswa Kira card.
 */
import SwiftUI

/** "Utang Bisa Diurus Bertahap" beside the 104 pt stairs, 4 pt in from the column. */
struct DebtEmergencyHeader: View {
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        HStack(alignment: .center, spacing: KiraSpacing.space3) {
            VStack(alignment: .leading, spacing: 10) {
                Text("debtEmergency.headline")
                    .font(KiraFont.display(28, .heavy, relativeTo: .title))
                    .kiraLineHeight(34, size: 28, natural: 1.26, relativeTo: .title)
                    .tracking(-28 * 0.02)
                    .foregroundStyle(.ink)
                    .accessibilityAddTraits(.isHeader)
                KiraTag("debtEmergency.free", tone: .pandan, icon: .heart)
                Text("debtEmergency.prompt")
                    .font(.body).kiraLineHeight(23, size: 17).foregroundStyle(.inkMuted)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            /** The stairs give the words their width at the accessibility sizes. */
            if !typeSize.isAccessibilitySize {
                KiraIllustration(.stairs, size: 104)
            }
        }
        .padding(.horizontal, KiraSpacing.space1)
    }
}

/** Beasiswa Kira: a gift tile in the coping tone, two lines and a chevron, one button. */
struct DebtScholarshipCard: View {
    let onOpen: () -> Void

    var body: some View {
        Button(action: onOpen) {
            HStack(alignment: .top, spacing: KiraSpacing.space3) {
                KiraIcon(.gift, size: 22)
                    .foregroundStyle(.coping)
                    .frame(width: KiraSize.tap, height: KiraSize.tap)
                    .kiraCard(.copingSoft, border: .copingLine, cornerRadius: KiraRadius.small)
                VStack(alignment: .leading, spacing: 3) {
                    Text("debtEmergency.scholarship").font(.headline.weight(.semibold)).kiraLineHeight(22, size: 17)
                        .foregroundStyle(.ink)
                    Text("debtEmergency.scholarship.body").font(.subheadline).kiraLineHeight(20, size: 15)
                        .foregroundStyle(.inkMuted)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                KiraIcon(.chevronRight, size: 20).foregroundStyle(.inkMuted).frame(maxHeight: .infinity)
            }
            .padding(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 14))
            .kiraCard()
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("debtEmergency.scholarship.label"))
        .accessibilityAddTraits(.isLink)
    }
}
