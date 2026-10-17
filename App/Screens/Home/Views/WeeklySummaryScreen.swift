/**
 Ringkasan Mingguan (UNG-08, board RingkasanMingguan): where the week's money went, against the week
 before, day by day and by category, with a note written from the numbers and Lihat Riwayat. Opened
 from Beranda's weekly card.
 */
import APIClient
import Domain
import Features
import SwiftUI

struct WeeklySummaryScreen: View {
    @State private var model: WeeklySummaryModel
    private let onOpen: (AppRoute) -> Void
    @Environment(\.dismiss) private var dismiss

    init(service: any WeeklySummaryService, onOpen: @escaping (AppRoute) -> Void) {
        _model = State(initialValue: WeeklySummaryModel(service: service))
        self.onOpen = onOpen
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: KiraSpacing.space4) {
                KiraNavBar(
                    "summary.weekly.title", subtitle: subtitle, leading: .back("summary.weekly.back") { dismiss() }
                ) {
                    KiraHelpButton(.icon) { onOpen(.care) }
                }
                content
            }
            .padding(.horizontal, KiraSpacing.screen)
            .padding(.bottom, KiraSpacing.space8)
        }
        .kiraScrollEdges()
        .background(alignment: .top) { WeeklySummaryLeaves() }
        .background(.surface)
        .toolbar(.hidden, for: .navigationBar)
        .task { await model.load() }
    }

    private var subtitle: LocalizedStringResource? {
        model.phase.value.map { "summary.weekly.range \($0.rangeText)" }
    }

    @ViewBuilder private var content: some View {
        switch model.phase {
        case .loading:
            WeeklySummaryContent(summary: .sample, onHistory: {}).redacted(reason: .placeholder).disabled(true)
        case .loaded(let summary):
            WeeklySummaryContent(summary: summary) { onOpen(.history) }
        case .empty:
            KiraNotice(.info, title: "summary.weekly.empty.title", message: "summary.weekly.empty")
        case .failed(let problem):
            LoadFailedView(title: "summary.weekly.failed", problem: problem) { Task { await model.load() } }
                .padding(.top, KiraSpacing.space8)
        }
    }
}

/** The two soft leaves behind the top (ranting 150 at the right, pandan 110 at the left). */
private struct WeeklySummaryLeaves: View {
    var body: some View {
        ZStack(alignment: .top) {
            KiraLeaf(.twig, tone: .soft, size: 150, isFlipped: true)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .offset(x: 38, y: 24)
            KiraLeaf(.pandan, tone: .soft, size: 110)
                .frame(maxWidth: .infinity, alignment: .leading)
                .offset(x: -40, y: 150)
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}
