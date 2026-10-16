/**
 Detail Indikator (SKR-02 Dana Darurat, 02b Rasio Menabung, 02c Rasio Cicilan, 02d Utang
 Konsumtif, 02e Utang terhadap Aset, 02f Proteksi): where the person stands, the formula with
 their numbers, the ladder with "Kamu di Sini", and what the next rung takes. Opened by
 `AppRoute.indicator(key)`.
 */
import APIClient
import Domain
import Features
import SwiftUI

struct IndicatorScreen: View {
    @State private var model: IndicatorModel
    private let onOpen: (AppRoute) -> Void
    @Environment(\.dismiss) private var dismiss

    init(key: IndicatorKey, service: any ScoreService, onOpen: @escaping (AppRoute) -> Void) {
        _model = State(initialValue: IndicatorModel(key: key, service: service))
        self.onOpen = onOpen
    }

    var body: some View {
        Group {
            switch model.phase {
            case .loading:
                IndicatorContent(detail: .sample(model.key), onOpen: { _ in }, onBack: {})
                    .redacted(reason: .placeholder)
                    .disabled(true)
            case .loaded(let detail):
                IndicatorContent(detail: detail, onOpen: onOpen) { dismiss() }
            case .empty:
                LoadFailedView(title: "indicator.failed", problem: AppProblem()) { reload() }
            case .failed(let problem):
                LoadFailedView(title: "indicator.failed", problem: problem) { reload() }
            }
        }
        .background(.surface)
        .toolbar(.hidden, for: .navigationBar)
        .task { await model.load() }
    }

    private func reload() {
        Task { await model.load() }
    }
}

private struct IndicatorContent: View {
    let detail: IndicatorDetail
    let onOpen: (AppRoute) -> Void
    let onBack: () -> Void
    @Environment(\.dynamicTypeSize) private var typeSize

    private var indicator: ScoreIndicator { detail.indicator }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: KiraSpacing.space4) {
                KiraNavBar(
                    "indicator.navTitle", subtitle: indicator.group.groupTitle,
                    leading: .back("indicator.back", onBack)
                ) {
                    KiraHelpButton(.icon) { onOpen(.unavailable(.care)) }
                }
                header
                KiraScenery(height: 150)
                    .padding(.horizontal, -KiraSpacing.screen)
                    .padding(.top, -64)
                    .padding(.bottom, -84)
                    .accessibilityHidden(true)
                IndicatorPositionCard(detail: detail)
                IndicatorFormulaCard(indicator: indicator)
                IndicatorLadder(detail: detail)
                if let next = detail.nextRung { nextRungCard(next) }
                KiraNotice(.info, title: "indicator.why.title", message: detail.why)
                KiraNotice(.simulation, title: "indicator.simulation.title", message: "indicator.simulation.body")
            }
            .padding(.horizontal, KiraSpacing.screen)
            /** The board's 62 pt from the top of the screen, and its twig at 34 pt. */
            .padding(.top, 62 - 59)
            .padding(.bottom, KiraSpacing.space8)
            .background(alignment: .topTrailing) {
                KiraLeaf(.twig, tone: .soft, size: 130, isFlipped: true).offset(x: 38, y: 34 - 59)
                    .accessibilityHidden(true)
            }
        }
        .kiraScrollEdges()
    }

    /** "Langkah berikutnya": what the next rung takes and what it adds to the score. */
    private func nextRungCard(_ next: NextRung) -> some View {
        KiraNextStepCard(
            "indicator.next.title \(next.points)", message: detail.nextRungMessage(next),
            primaryLabel: detail.nextRungLabel, onPrimary: { onOpen(indicator.key.nextRungRoute) },
            onSecondary: onBack
        )
        .eyebrow("indicator.next.eyebrow")
        .illustration(.piggyBank)
        .impact("indicator.next.impact \(next.gain) \(next.scoreFrom) \(next.scoreTo)")
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: KiraSpacing.space3) {
            HStack(spacing: 14) {
                KiraCategoryIcon(indicator.key.category, size: 52)
                VStack(alignment: .leading, spacing: 6) {
                    Text(indicator.key.name)
                        .font(KiraFont.display(28, .heavy, relativeTo: .title))
                        .kiraLineHeight(34, size: 28, natural: 1.26, relativeTo: .title)
                        .tracking(-0.56)
                        .foregroundStyle(.ink)
                        .accessibilityAddTraits(.isHeader)
                    /** The band beside the points; under them at accessibility sizes. */
                    let row =
                        typeSize.isAccessibilitySize
                        ? AnyLayout(VStackLayout(alignment: .leading, spacing: KiraSpacing.space1))
                        : AnyLayout(HStackLayout(spacing: KiraSpacing.space2))
                    row {
                        Text("indicator.points \(indicator.points)")
                            .font(KiraFont.display(17, .heavy, relativeTo: .headline).monospacedDigit())
                            .kiraLineHeight(22, size: 17, natural: 1.26, relativeTo: .headline)
                            .foregroundStyle(.ink)
                        KiraBandPill(indicator.band, size: .small)
                    }
                }
            }
            Text(indicator.key.summary).font(.subheadline).kiraLineHeight(21, size: 15).foregroundStyle(.inkMuted)
        }
        .padding(
            EdgeInsets(top: KiraSpacing.space2, leading: KiraSpacing.space1, bottom: 0, trailing: KiraSpacing.space1))
    }
}
