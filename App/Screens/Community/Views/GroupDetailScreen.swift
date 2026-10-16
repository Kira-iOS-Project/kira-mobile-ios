/**
 Detail Grup (KOM-02): one verified group with its admin, what it is for, its three main rules and
 the day its link was checked. "Gabung Grup" goes through Aturan Komunitas (KOM-03) when needed and
 always through Tautan Keluar (KOM-04); "Laporkan Grup" (KOM-05) is red, for everyone.
 */
import APIClient
import Domain
import Features
import SwiftUI

struct GroupDetailScreen: View {
    @State private var model: GroupDetailModel
    private let onOpen: (AppRoute) -> Void
    @Environment(\.dismiss) private var dismiss

    init(groupID: String, service: any CommunityService, onOpen: @escaping (AppRoute) -> Void) {
        _model = State(initialValue: GroupDetailModel(groupID: groupID, service: service))
        self.onOpen = onOpen
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: KiraSpacing.space4) {
                KiraNavBar(
                    "community.detail.title", subtitle: model.phase.value.map { $0.summary.category.title },
                    leading: .back("community.detail.back") { dismiss() }
                ) {
                    KiraHelpButton(.icon) { onOpen(.care) }
                }
                content
            }
            .padding(.horizontal, KiraSpacing.screen)
            .padding(.top, KiraSpacing.space1)
            .padding(.bottom, KiraSpacing.space2)
        }
        .background(alignment: .topTrailing) {
            KiraLeaf(.twig, tone: .soft, size: 130, isFlipped: true).offset(x: 38, y: 34).ignoresSafeArea()
                .accessibilityHidden(true)
        }
        .background(.surface)
        .kiraScrollEdges()
        .toolbar(.hidden, for: .navigationBar)
        .task { await model.load() }
        .modifier(GroupDetailCovers(model: model) { dismiss() })
    }

    @ViewBuilder private var content: some View {
        switch model.phase {
        case .loading, .empty:
            ProgressView().frame(maxWidth: .infinity, minHeight: 240)
                .accessibilityLabel(Text("community.loading"))
        case .failed(let problem):
            LoadFailedView(problem: problem) { Task { await model.load() } }
        case .loaded(let group):
            GroupHeader(group: group)
            GroupAbout(group: group)
            VStack(spacing: KiraSpacing.space2) {
                KiraButton("community.detail.join") { Task { await model.join() } }
                    .block()
                    .disabled(model.isWorking)
                KiraButton("community.detail.report", variant: .emergency) { model.report() }
                    .icon(.flag)
                    .block()
            }
            .padding(.top, KiraSpacing.space1)
        }
    }
}
