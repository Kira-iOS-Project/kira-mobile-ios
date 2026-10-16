/**
 The indicator's "Posisimu" and "Rumusnya" cards, and "Aturan Nilai", its ladder with the
 person's rung marked "Kamu di Sini".
 */
import Domain
import SwiftUI

struct IndicatorPositionCard: View {
    let detail: IndicatorDetail

    var body: some View {
        VStack(alignment: .leading, spacing: KiraSpacing.space4) {
            VStack(alignment: .leading, spacing: 6) {
                Text("indicator.position.overline").kiraFont(.overline).foregroundStyle(.inkMuted).kiraSmallType()
                detail.indicator.measure.valueText.kiraFont(.title).foregroundStyle(.ink)
                detail.indicator.measure.positionText.font(.subheadline).kiraLineHeight(20, size: 15)
                    .foregroundStyle(.inkMuted)
            }
            if let ribbon = detail.indicator.measure.ribbon {
                KiraProgressRibbon(
                    value: Double(ribbon.value),
                    target: Double(ribbon.target)
                )
                .milestones(detail.milestones.map(\.ribbonMilestone))
                .caption(ribbon.caption)
            }
        }
        .padding(KiraSpacing.space5)
        .frame(maxWidth: .infinity, alignment: .leading)
        .kiraCard()
    }
}

struct IndicatorFormulaCard: View {
    let indicator: ScoreIndicator

    var body: some View {
        VStack(alignment: .leading, spacing: KiraSpacing.space3) {
            Text("indicator.formula.overline").kiraFont(.overline).foregroundStyle(.inkMuted).kiraSmallType()
            Text(indicator.key.formulaTitle).font(.callout.weight(.semibold)).kiraLineHeight(21, size: 16)
                .foregroundStyle(.ink)
            VStack(alignment: .leading, spacing: 0) {
                indicator.formulaInput
                indicator.formulaResult
            }
            .kiraFont(.formula)
            .foregroundStyle(.ink)
            .padding(.vertical, 10)
            .padding(.horizontal, KiraSpacing.space3)
            .frame(maxWidth: .infinity, alignment: .leading)
            .kiraCard(.surface, cornerRadius: KiraRadius.small)
            Text(indicator.key.source).font(.footnote).kiraLineHeight(18, size: 13).foregroundStyle(.inkMuted)
        }
        .padding(KiraSpacing.space5)
        .frame(maxWidth: .infinity, alignment: .leading)
        .kiraCard()
    }
}

struct IndicatorLadder: View {
    let detail: IndicatorDetail

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if detail.nextRung == nil {
                KiraSectionTitle("indicator.ladder.title")
            } else {
                KiraSectionTitle("indicator.ladder.title", trailing: .note(detail.indicator.key.ladderNote))
            }
            VStack(spacing: 2) {
                ForEach(detail.ladder, id: \.points) { rung in
                    IndicatorRungRow(title: detail.title(of: rung), detail: detail.detail(of: rung), rung: rung)
                }
            }
            .padding(KiraSpacing.space2)
            .kiraCard()
        }
        .padding(.top, KiraSpacing.space1)
    }
}

private struct IndicatorRungRow: View {
    let title: Text
    let detail: Text
    let rung: LadderRung

    var body: some View {
        HStack(spacing: KiraSpacing.space3) {
            VStack(spacing: 0) {
                Text(rung.points, format: .number)
                    .font(KiraFont.display(17, .heavy, relativeTo: .headline).monospacedDigit())
                    .kiraLineHeight(20, size: 17, natural: 1.26, relativeTo: .headline)
                Text("indicator.rung.unit").font(.caption2.weight(.semibold)).kiraLineHeight(13, size: 11)
                    .foregroundStyle(rung.isCurrent ? Color.onPandan : .inkMuted)
                    .kiraSmallType()
            }
            .foregroundStyle(rung.isCurrent ? Color.onPandan : .ink)
            .frame(width: 48, height: 48)
            .kiraCard(
                rung.isCurrent ? .pandan : .surfaceMuted, border: rung.isCurrent ? .pandan : .hairline,
                cornerRadius: KiraRadius.small)
            VStack(alignment: .leading, spacing: 2) {
                title.font(.callout.weight(.semibold)).kiraLineHeight(21, size: 16).foregroundStyle(.ink)
                detail.font(.footnote).kiraLineHeight(18, size: 13).foregroundStyle(.inkMuted)
                if rung.isCurrent { here.padding(.top, KiraSpacing.space1) }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(10)
        .kiraCard(
            rung.isCurrent ? .pandanSoft : .clear, border: rung.isCurrent ? .pandanLine : .clear,
            cornerRadius: KiraRadius.medium
        )
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(rung.isCurrent ? .isSelected : [])
    }

    private var here: some View {
        HStack(spacing: KiraSpacing.space1) {
            KiraIcon(.mapPin, size: 14, weight: .bold)
            Text("indicator.rung.here")
        }
        .font(.caption.weight(.bold)).kiraLineHeight(16, size: 12)
        .foregroundStyle(.onPandan)
        .padding(.leading, KiraSpacing.space2)
        .padding(.trailing, 10)
        .frame(minHeight: 24)
        .background(.pandan, in: Capsule())
    }
}
