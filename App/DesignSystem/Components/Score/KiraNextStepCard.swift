/**
 NextStepCard (design system): the one next step on Beranda, with its illustration, its computed
 effect and an equal "Nanti Saja". The order of steps comes from rules (costly debt, then the
 emergency fund, protection, investing), never from AI. Under a "Langkah Berikutnya" section
 title, change the eyebrow ("Prioritas") so it does not repeat. Illustrations: kartu-lunas for a
 payoff, celengan for the emergency fund, payung for protection, struk for recording.
 */
import SwiftUI

/** The next step: an eyebrow, a title, why, its effect, and two equal buttons. */
struct KiraNextStepCard: View {
    private let title: LocalizedStringResource
    private let message: LocalizedStringResource?
    private let primaryLabel: LocalizedStringResource
    private let onPrimary: () -> Void
    private let onSecondary: () -> Void
    private var eyebrow: LocalizedStringResource = "ds.step.eyebrow"
    private var meta: LocalizedStringResource?
    private var illustration: KiraIllustrationName?
    private var impact: LocalizedStringResource?
    private var secondaryLabel: LocalizedStringResource = "ds.later"

    init(
        _ title: LocalizedStringResource, message: LocalizedStringResource? = nil,
        primaryLabel: LocalizedStringResource, onPrimary: @escaping () -> Void, onSecondary: @escaping () -> Void
    ) {
        self.title = title
        self.message = message
        self.primaryLabel = primaryLabel
        self.onPrimary = onPrimary
        self.onSecondary = onSecondary
    }

    var body: some View {
        VStack(alignment: .leading, spacing: KiraSpacing.space3) {
            HStack(spacing: KiraSpacing.space3) {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: KiraSpacing.space2) {
                        Text(eyebrow).kiraFont(.overline).foregroundStyle(.pandan)
                        if let meta { metaPill(meta) }
                    }
                    Text(title)
                        .font(KiraFont.display(21, .heavy, relativeTo: .title3))
                        .tracking(-0.3)
                        .foregroundStyle(.ink)
                        .accessibilityAddTraits(.isHeader)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                if let illustration { KiraIllustration(illustration, size: 76).padding(-4) }
            }
            if let message { Text(message).font(.subheadline).foregroundStyle(.inkMuted) }
            if let impact { impactChip(impact) }
            KiraButtonPair(
                secondary: KiraButton(secondaryLabel, variant: .secondary, action: onSecondary),
                primary: KiraButton(primaryLabel, action: onPrimary))
        }
        .padding(KiraSpacing.space5)
        .kiraCard()
    }

    private func metaPill(_ text: LocalizedStringResource) -> some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .foregroundStyle(.inkMuted)
            .padding(.horizontal, 7)
            .padding(.vertical, 1)
            .capsuleHairline()
    }

    private func impactChip(_ text: LocalizedStringResource) -> some View {
        HStack(spacing: 6) {
            KiraIcon(.trendUp, size: 16, weight: .semibold)
            Text(text)
        }
        .font(.footnote.weight(.semibold).monospacedDigit())
        .foregroundStyle(.pandan)
        .padding(.vertical, KiraSpacing.space2)
        .padding(.horizontal, KiraSpacing.space3)
        .kiraCard(.pandanSoft, border: .pandanLine, cornerRadius: KiraRadius.small)
        .padding(.top, KiraSpacing.space1)
    }

    /** The same card with another eyebrow ("Prioritas"). */
    func eyebrow(_ text: LocalizedStringResource) -> Self { copy { $0.eyebrow = text } }

    /** The same card with a small pill beside the eyebrow ("1 dari 3"). */
    func meta(_ text: LocalizedStringResource) -> Self { copy { $0.meta = text } }

    /** The same card with a spot illustration at its top right. */
    func illustration(_ name: KiraIllustrationName) -> Self { copy { $0.illustration = name } }

    /** The same card with the engine-computed effect ("Perkiraan Kira Score 66 → 71"). */
    func impact(_ text: LocalizedStringResource) -> Self { copy { $0.impact = text } }

    /** The same card with another secondary label than "Nanti Saja". */
    func secondaryLabel(_ text: LocalizedStringResource) -> Self { copy { $0.secondaryLabel = text } }

    private func copy(_ change: (inout Self) -> Void) -> Self {
        var card = self
        change(&card)
        return card
    }
}

#if DEBUG
    #Preview { GalleryScore().galleryPage() }
#endif
