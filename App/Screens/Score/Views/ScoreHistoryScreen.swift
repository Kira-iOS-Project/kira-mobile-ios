/**
 Riwayat Kira Score (SKR-07 6 Bulan, SKR-07b 1 Tahun; boards RiwayatSkor, RiwayatSkorTahun): the
 score now with its move since last month, 6 Bulan or 1 Tahun of monthly bars, what changed this
 month, each row opening its indicator. Opened by `AppRoute.scoreHistory` from Kira Score's
 "Lihat Riwayat Skor" on Kira Plus; a plan without it (403 PLAN_FEATURE_UNAVAILABLE) gets Lihat
 Paket. The board's "Butuh minimal satu bulan data" notice shows in every state.
 */
import APIClient
import Domain
import Features
import SwiftUI

struct ScoreHistoryScreen: View {
    @State private var model: ScoreHistoryModel
    private let onOpen: (AppRoute) -> Void
    @Environment(\.dismiss) private var dismiss

    init(service: any ScoreService, onOpen: @escaping (AppRoute) -> Void) {
        _model = State(initialValue: ScoreHistoryModel(service: service))
        self.onOpen = onOpen
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: KiraSpacing.space4) {
                KiraNavBar(
                    "score.history.title", subtitle: "score.history.subtitle",
                    leading: .back("indicator.back") { dismiss() }
                ) {
                    KiraHelpButton(.icon) { onOpen(.care) }
                }
                content
            }
            .padding(.horizontal, KiraSpacing.screen)
            /** The board's 62 pt from the top of the screen. */
            .padding(.top, 62 - 59)
            .padding(.bottom, KiraSpacing.screenBottom)
        }
        .kiraScrollEdges()
        .background(alignment: .topTrailing) {
            KiraLeaf(.twig, tone: .soft, size: 130, isFlipped: true)
                .offset(x: 38, y: -25)
                .allowsHitTesting(false)
                .accessibilityHidden(true)
        }
        .background(.surface)
        .toolbar(.hidden, for: .navigationBar)
        .task { await model.load() }
    }

    @ViewBuilder private var content: some View {
        switch model.phase {
        case .loading:
            ScoreHistoryContent(history: .sample(.sixMonths), model: nil, onOpen: { _ in })
                .redacted(reason: .placeholder)
                .disabled(true)
        case .loaded(let history):
            ScoreHistoryContent(history: history, model: model, onOpen: onOpen)
        case .empty:
            KiraNotice(.info, message: "score.history.notice")
        case .failed where model.needsPlan:
            KiraNotice(.info, message: "score.history.notice")
            KiraNotice(.info, message: "score.history.plusOnly")
            KiraButton("score.history.plans", variant: .secondary) { onOpen(.plans(yearly: false)) }.block()
        case .failed(let problem):
            KiraNotice(.info, message: "score.history.notice")
            LoadFailedView(title: "score.history.failed", problem: problem) { Task { await model.load() } }
                .padding(.top, KiraSpacing.space8)
        }
    }
}

/** Everything under the navigation bar, as the boards lay it out. */
private struct ScoreHistoryContent: View {
    let history: ScoreHistory
    /** Nil while the placeholder shows. */
    let model: ScoreHistoryModel?
    let onOpen: (AppRoute) -> Void

    var body: some View {
        ScoreHistoryCard(history: history, model: model)
        KiraNotice(.info, message: "score.history.notice")
        if !history.changes.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                KiraSectionTitle("score.history.changes")
                KiraListGroup {
                    ForEach(history.changes, id: \.indicator) { change in
                        ScoreChangeRow(change: change) { onOpen(.indicator(change.indicator)) }
                    }
                }
                .accessibilityElement(children: .contain)
                .accessibilityLabel(Text("score.history.changes.label"))
                history.footer
                    .font(.footnote).kiraLineHeight(18, size: 13)
                    .foregroundStyle(.inkMuted)
                    .padding(.horizontal, KiraSpacing.space1)
            }
            .padding(.top, KiraSpacing.space1)
        }
        KiraNotice(.simulation, title: "indicator.simulation.title", message: "score.history.simulation")
    }
}

/** One changed indicator: its tile, name, labels before and now, points, and the gain. */
private struct ScoreChangeRow: View {
    let change: IndicatorChange
    let onOpen: () -> Void

    var body: some View {
        KiraListRow(Text(change.indicator.name), leading: .category(change.indicator.category), action: onOpen) {
            let gained = change.gain >= 0
            KiraTag(change.gainText, tone: gained ? .healthy : .neutral, icon: gained ? .trendUp : nil)
        }
        .subtitle(change.labels)
        .value(Text(change.pointsText))
    }
}
