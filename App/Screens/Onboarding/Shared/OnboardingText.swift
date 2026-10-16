/**
 The text styles the onboarding boards repeat: the 30 pt display heading, the 24 pt quiz question,
 the 17/24 lead in ink-muted under a heading, and the pandan overline above it.
 */
import SwiftUI

/** The big heading of an onboarding board ("Halo, Aku Kuku"): Plus Jakarta Sans 30/36 ExtraBold. */
struct OnboardingHeading: View {
    let text: LocalizedStringResource
    var size: CGFloat = 30

    var body: some View {
        Text(text)
            .font(KiraFont.display(size, .heavy, relativeTo: .title))
            .kiraLineHeight(size + 6, size: size, natural: 1.26, relativeTo: .title)
            .tracking(-0.025 * size)
            .foregroundStyle(.ink)
            .accessibilityAddTraits(.isHeader)
    }
}

/** The question of a quiz step ("Berapa Penghasilanmu per Bulan?"): 24/30 ExtraBold. */
struct QuizQuestion: View {
    let text: LocalizedStringResource

    var body: some View {
        Text(text)
            .font(KiraFont.display(24, .heavy, relativeTo: .title2))
            .kiraLineHeight(30, size: 24, natural: 1.26, relativeTo: .title2)
            .tracking(-0.48)
            .foregroundStyle(.ink)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, KiraSpacing.space1)
            .padding(.top, KiraSpacing.space1)
            .accessibilityAddTraits(.isHeader)
    }
}

extension Text {
    /** The 17/24 ink-muted sentence under a heading. */
    func onboardingLead() -> some View {
        font(.body).kiraLineHeight(24, size: 17).foregroundStyle(.inkMuted)
    }

    /** The pandan overline above a heading ("Kenalan dulu"). */
    func onboardingOverline() -> some View {
        kiraFont(.overline).foregroundStyle(.pandan)
    }

    /** A 13/18 ink-muted note under a field or a group. */
    func onboardingNote() -> some View {
        font(.footnote).kiraLineHeight(18, size: 13).foregroundStyle(.inkMuted)
    }
}
