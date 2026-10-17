/**
 The head of Rencana Keselamatanku and its form (boards RencanaKeselamatan, RencanaKeselamatanIsi):
 the outline back button, then the 28 pt title over its 17 pt line beside the 88 pt `peduli`
 illustration, inset 4 pt as the boards' grid is.
 */
import SwiftUI

struct SafetyPlanHeader: View {
    let title: LocalizedStringResource
    let lead: LocalizedStringResource
    let back: LocalizedStringResource
    let onBack: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: KiraSpacing.space3) {
            KiraIconButton.back(back, action: onBack)
            HStack(alignment: .center, spacing: KiraSpacing.space3) {
                VStack(alignment: .leading, spacing: KiraSpacing.space2) {
                    Text(title)
                        .font(KiraFont.display(28, .heavy, relativeTo: .largeTitle))
                        .kiraLineHeight(34, size: 28, natural: 1.26, relativeTo: .largeTitle)
                        .tracking(-0.56)
                        .foregroundStyle(.ink)
                        .accessibilityAddTraits(.isHeader)
                    Text(lead).font(.body).kiraLineHeight(23, size: 17).foregroundStyle(.inkMuted)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                KiraIllustration(.care, size: 88)
            }
            .padding(.horizontal, KiraSpacing.space1)
        }
    }
}
