/**
 The two blocks every debt guide draws: the pandan card with its four points and their basis, and
 Langkahmu's four numbered steps joined by a line.
 */
import SwiftUI

/** The pandan card: a 40 pt tile, the heading and its lead, four points, the basis under a line. */
struct DebtGuideCard: View {
    let content: DebtGuideContent

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: KiraSpacing.space3) {
                KiraIcon(content.icon, size: 22)
                    .foregroundStyle(.pandan)
                    .frame(width: KiraSize.tile, height: KiraSize.tile)
                    .kiraCard(.surfaceRaised, border: .pandanLine, cornerRadius: KiraRadius.small)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 1) {
                    Text(content.heading)
                        .font(KiraFont.display(22, .heavy, relativeTo: .title2))
                        .kiraLineHeight(28, size: 22, natural: 1.26, relativeTo: .title2)
                        .tracking(-22 * 0.015)
                        .foregroundStyle(.ink)
                        .accessibilityAddTraits(.isHeader)
                    Text(content.lead).font(.subheadline).kiraLineHeight(20, size: 15).foregroundStyle(.inkMuted)
                }
            }
            VStack(alignment: .leading, spacing: 10) {
                ForEach(content.points.indices, id: \.self) { index in
                    point(content.points[index])
                }
            }
            Text(content.basis)
                .font(.caption.weight(.medium)).kiraLineHeight(16, size: 12).foregroundStyle(.inkMuted)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, KiraSpacing.space3)
                .overlay(alignment: .top) { Rectangle().fill(.pandanLine).frame(height: 1) }
        }
        .padding(EdgeInsets(top: 20, leading: 18, bottom: 16, trailing: 18))
        .kiraCard(.pandanSoft, border: .pandanLine)
    }

    private func point(_ text: LocalizedStringResource) -> some View {
        HStack(alignment: .top, spacing: KiraSpacing.space3) {
            let avoids = content.marker == .avoid
            KiraIcon(avoids ? .close : .check, size: 13, weight: .heavy)
                .foregroundStyle(avoids ? Color.vulnerable : .pandan)
                .frame(width: KiraSize.icon, height: KiraSize.icon)
                .background(.surfaceRaised, in: Circle())
                .overlay { Circle().strokeBorder(avoids ? Color.vulnerableLine : .pandanLine, lineWidth: 1) }
                .accessibilityHidden(true)
            Text(text).font(.callout).kiraLineHeight(22, size: 16).foregroundStyle(.ink)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

/** Langkahmu: the section title and the steps in a hairline card, the first number filled. */
struct DebtGuideSteps: View {
    let steps: [(title: LocalizedStringResource, detail: LocalizedStringResource)]
    /** The 30 pt number disc grows with its number. */
    @ScaledMetric(relativeTo: .subheadline) private var disc: CGFloat = 30

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            KiraSectionTitle("debtGuide.steps")
            VStack(spacing: 0) {
                ForEach(steps.indices, id: \.self) { index in
                    step(index)
                }
            }
            .padding(.vertical, 18)
            .padding(.horizontal, KiraSpacing.space4)
            .kiraCard()
        }
    }

    /**
     One step: the number over the line down to the next number (4 pt clear of both discs; the last
     step has none), and the words, 24 pt above the next step.
     */
    private func step(_ index: Int) -> some View {
        let isLast = index == steps.count - 1
        return HStack(alignment: .top, spacing: 14) {
            VStack(spacing: KiraSpacing.space1) {
                Text(index + 1, format: .number)
                    .font(KiraFont.display(14, .heavy, relativeTo: .subheadline))
                    .foregroundStyle(index == 0 ? Color.onPandan : .pandan)
                    .frame(width: disc, height: disc)
                    .background(index == 0 ? Color.pandan : .pandanSoft, in: Circle())
                    .overlay { Circle().strokeBorder(index == 0 ? Color.clear : .pandanLine, lineWidth: 1) }
                if !isLast {
                    Capsule().fill(.line).frame(width: 1.5).frame(maxHeight: .infinity)
                        .padding(.bottom, KiraSpacing.space1)
                        .accessibilityHidden(true)
                }
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(steps[index].title).font(.callout.weight(.semibold)).kiraLineHeight(21, size: 16)
                    .foregroundStyle(.ink)
                Text(steps[index].detail).font(.subheadline).kiraLineHeight(19, size: 14).foregroundStyle(.inkMuted)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, KiraSpacing.space1)
            .padding(.bottom, isLast ? 0 : KiraSpacing.space6)
        }
        .fixedSize(horizontal: false, vertical: true)
        .accessibilityElement(children: .combine)
    }
}
