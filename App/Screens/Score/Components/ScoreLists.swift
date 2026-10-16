/**
 The score's two lists: "Tiga Langkah Prioritas", the engine's steps numbered in order, and
 "Enam Indikator", one card per group with its points and its indicators.
 */
import Domain
import Features
import SwiftUI

struct ScoreStepList: View {
    let steps: [ScoreStep]
    let onOpen: (AppRoute) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: KiraSpacing.space3) {
            ScoreListTitle(title: title)
            VStack(spacing: KiraSpacing.space2) {
                ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                    ScoreStepCard(step: step, number: index + 1) { onOpen(step.route) }
                }
            }
        }
    }

    private var title: LocalizedStringResource {
        switch steps.count {
        case 1: "score.steps.one"
        case 2: "score.steps.two"
        default: "score.steps.three"
        }
    }
}

private struct ScoreStepCard: View {
    let step: ScoreStep
    let number: Int
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: 14) {
                KiraCategoryIcon(step.category)
                    .overlay(alignment: .topLeading) { badge.offset(x: -7, y: -7) }
                VStack(alignment: .leading, spacing: 2) {
                    Text(step.title).font(.headline).kiraLineHeight(22, size: 17).foregroundStyle(.ink)
                    Text(step.message(masked: false)).font(.subheadline).kiraLineHeight(20, size: 15)
                        .foregroundStyle(.inkMuted)
                    Text("score.steps.gain \(step.estimatedGain)")
                        .font(.caption.weight(.bold).monospacedDigit()).kiraLineHeight(16, size: 12)
                        .foregroundStyle(.pandan)
                        .padding(.vertical, 3).padding(.horizontal, 9)
                        .kiraCard(.pandanSoft, border: .pandanLine, cornerRadius: KiraRadius.full)
                        .padding(.top, 6)
                    if step.kind == .payOffDebt {
                        Text("step.destination.plan").font(.subheadline.weight(.semibold))
                            .kiraLineHeight(20, size: 15).foregroundStyle(.pandan).padding(.top, KiraSpacing.space1)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                KiraIcon(.chevronRight, size: 20).foregroundStyle(.inkMuted).frame(maxHeight: .infinity)
            }
            .padding(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 14))
            .kiraCard(cornerRadius: KiraRadius.medium)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("score.steps.label \(Text(step.title)) \(step.destinationLabel)"))
        .accessibilityAddTraits(.isButton)
    }

    private var badge: some View {
        Text(number, format: .number)
            .font(KiraFont.display(11, .heavy, relativeTo: .caption2))
            .foregroundStyle(number == 1 ? Color.onPandan : .ink)
            .frame(width: 20, height: 20)
            .background(number == 1 ? Color.pandan : .surfaceMuted, in: Circle())
            .overlay { Circle().strokeBorder(.surfaceRaised, lineWidth: 2) }
            .kiraSmallType()
            .accessibilityHidden(true)
    }
}

struct ScoreIndicatorGroups: View {
    let report: ScoreReport
    let onOpen: (AppRoute) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: KiraSpacing.space3) {
            ScoreListTitle(title: "score.indicators.title")
            ForEach(report.orderedGroups, id: \.group) { group in
                KiraRowStack {
                    header(group)
                    ForEach(report.indicators(in: group.group), id: \.key) { indicator in
                        row(indicator)
                    }
                }
                .padding(.vertical, KiraSpacing.space1)
                .padding(.horizontal, KiraSpacing.space4)
                .kiraCard()
            }
        }
    }

    private func header(_ group: GroupScore) -> some View {
        HStack(alignment: .top, spacing: KiraSpacing.space3) {
            KiraCategoryIcon(group.group.category)
            VStack(alignment: .leading, spacing: KiraSpacing.space1) {
                Text(group.group.name).kiraFont(.overline).foregroundStyle(.inkMuted).kiraSmallType()
                Text(group.points, format: .number)
                    .font(KiraFont.display(17, .heavy, relativeTo: .headline).monospacedDigit())
                    .kiraLineHeight(22, size: 17, natural: 1.26, relativeTo: .headline)
                    .foregroundStyle(.ink)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            KiraBandPill(group.band, size: .small)
        }
        .padding(.top, 14)
        .padding(.bottom, KiraSpacing.space3)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
    }

    private func row(_ indicator: ScoreIndicator) -> some View {
        var row = KiraIndicatorRow(
            name: Text(indicator.key.name), value: indicator.measure.rowValue, points: Score(indicator.points)
        ) { onOpen(.indicator(indicator.key)) }
        .band(indicator.band)
        if let target = indicator.measure.rowTarget { row = row.target(target.text) }
        return row
    }
}

/** A list's title with its small leaf (t-title). */
private struct ScoreListTitle: View {
    let title: LocalizedStringResource

    var body: some View {
        HStack(spacing: KiraSpacing.space2) {
            KiraLeaf(.single, size: 20)
            Text(title).kiraFont(.title).foregroundStyle(.ink)
        }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
    }
}
