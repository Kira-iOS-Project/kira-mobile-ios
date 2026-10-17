/**
 Kira Score (SKR-01, the formula open is SKR-01b): the score on its meter, how it is computed, the
 engine's steps and the six indicators by group. Pushed from Beranda; each indicator opens
 `AppRoute.indicator` through `onOpen`.
 */
import APIClient
import Domain
import Features
import SwiftUI

struct ScoreScreen: View {
    @State private var model: ScoreModel
    private let onOpen: (AppRoute) -> Void
    @Environment(\.dismiss) private var dismiss

    init(service: any ScoreService, onOpen: @escaping (AppRoute) -> Void) {
        _model = State(initialValue: ScoreModel(service: service))
        self.onOpen = onOpen
    }

    var body: some View {
        Group {
            switch model.phase {
            case .loading:
                ScoreContent(report: .sample, historyRoute: .scoreHistory, onOpen: { _ in }, onBack: {})
                    .redacted(reason: .placeholder)
                    .disabled(true)
            case .loaded(let report):
                ScoreContent(report: report, historyRoute: model.historyRoute, onOpen: onOpen) { dismiss() }
            case .empty:
                ScoreEmptyView(onOpen: onOpen) { dismiss() }
            case .failed(let problem):
                LoadFailedView(title: "score.failed", problem: problem) { Task { await model.load() } }
            }
        }
        .background(.surface)
        .toolbar(.hidden, for: .navigationBar)
        .task { await model.load() }
    }
}

/** The loaded score, top to bottom as the board lays it. */
private struct ScoreContent: View {
    let report: ScoreReport
    /** Where "Lihat Riwayat Skor" leads for this plan. */
    let historyRoute: AppRoute
    let onOpen: (AppRoute) -> Void
    let onBack: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: KiraSpacing.space5) {
                ScoreHeader(report: report, onOpen: onOpen, onBack: onBack)
                ScoreFormulaAccordion(report: report)
                ScoreSummaryCard(report: report) { onOpen(historyRoute) }
                if !report.steps.isEmpty {
                    ScoreStepList(steps: report.steps, onOpen: onOpen)
                }
                ScoreIndicatorGroups(report: report, onOpen: onOpen)
                Text("score.privacy").font(.footnote).kiraLineHeight(18, size: 13).foregroundStyle(.inkMuted)
            }
            .padding(.horizontal, KiraSpacing.screen)
            /** The board's 62 pt from the top of the screen, and its scenery at 96 pt. */
            .padding(.top, 62 - 59)
            .padding(.bottom, KiraSpacing.space10)
            .background(alignment: .top) {
                KiraScenery(hasSun: true, height: 150).offset(y: 96 - 59).accessibilityHidden(true)
            }
        }
        .kiraScrollEdges()
    }
}

/** The back button and Kira Peduli, the title, and when the score was computed and is next due. */
private struct ScoreHeader: View {
    let report: ScoreReport
    let onOpen: (AppRoute) -> Void
    let onBack: () -> Void
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        VStack(alignment: .leading, spacing: KiraSpacing.space1) {
            HStack {
                KiraIconButton.back("score.back", action: onBack)
                Spacer(minLength: KiraSpacing.space2)
                KiraHelpButton { onOpen(.care) }
                    /** At accessibility sizes it wraps rather than widen the page. */
                    .fixedSize(horizontal: !typeSize.isAccessibilitySize, vertical: true)
            }
            .frame(minHeight: KiraSize.tap)
            Text("score.title").kiraFont(.largeTitle).foregroundStyle(.ink).accessibilityAddTraits(.isHeader)
            Text("score.computed \(computed) \(nextCheck)")
                .font(.footnote.weight(.medium)).kiraLineHeight(18, size: 13).foregroundStyle(.inkMuted)
        }
        .padding(.bottom, KiraSpacing.space3)
    }

    private var computed: Text { Text(report.computedAt, format: .kiraDate) }
    private var nextCheck: Text { Text(report.nextCheckOn, format: .kiraDate) }
}

/** Before the health check: no score yet, and the way to get one. */
private struct ScoreEmptyView: View {
    let onOpen: (AppRoute) -> Void
    let onBack: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: KiraSpacing.space4) {
            KiraIconButton.back("score.back", action: onBack)
            Spacer()
            VStack(spacing: KiraSpacing.space3) {
                KiraIllustration(.sprout, size: 128)
                Text("score.empty.title").kiraFont(.title).foregroundStyle(.ink).accessibilityAddTraits(.isHeader)
                Text("score.empty.body").kiraFont(.callout).foregroundStyle(.inkMuted)
                KiraButton("score.empty.start") { onOpen(.healthCheck) }.padding(.top, KiraSpacing.space2)
            }
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            Spacer()
        }
        .padding(KiraSpacing.screen)
    }
}
