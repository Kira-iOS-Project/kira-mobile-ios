/**
 Komunitas (KOM-01), the Komunitas tab's root: a warm intro, the category chips, the verified
 groups in the curators' order, the way to Etalase, and the community rules, with the help pill to
 Kira Peduli. The dock stays.
 */
import Domain
import Features
import SwiftUI

struct CommunityScreen: View {
    @State private var model: CommunityModel
    @State private var readsRules = false
    private let onOpen: (AppRoute) -> Void

    init(service: any CommunityService, onOpen: @escaping (AppRoute) -> Void) {
        _model = State(initialValue: CommunityModel(service: service))
        self.onOpen = onOpen
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: KiraSpacing.space4) {
                KiraNavBar("community.title", isLarge: true) {
                    KiraHelpButton(.pill) { onOpen(.unavailable(.care)) }
                }
                .eyebrow("community.eyebrow")
                CommunityIntro()
                content
            }
            .padding(.horizontal, KiraSpacing.screen)
            .padding(.top, KiraSpacing.space1)
            .padding(.bottom, KiraSpacing.space10)
        }
        .background(alignment: .topTrailing) {
            KiraLeaf(.twig, tone: .soft, size: 150, isFlipped: true).offset(x: 34, y: 30).ignoresSafeArea()
                .accessibilityHidden(true)
        }
        .background(.surface)
        .kiraScrollEdges()
        .toolbar(.hidden, for: .navigationBar)
        .task { await model.load() }
        .refreshable { await model.load() }
        .kiraSheet(isPresented: $readsRules, title: "community.rules.title", subtitle: "community.rules.subtitle") {
            CommunityRulesList()
        }
    }

    @ViewBuilder private var content: some View {
        switch model.phase {
        case .loading:
            ProgressView().frame(maxWidth: .infinity, minHeight: 200)
                .accessibilityLabel(Text("community.loading"))
        case .failed(let problem):
            LoadFailedView(problem: problem) { Task { await model.load() } }
        case .empty, .loaded:
            CommunityChips(model: model)
            CommunityGroups(groups: model.groups, isEmpty: model.phase.value == nil) {
                onOpen(.communityGroup(id: $0.id))
            }
            KiraTapCard(.book, label: Text("community.marketplace.label")) {
                onOpen(.marketplace)
            } content: {
                Text("community.marketplace.title").kiraFont(.headline).foregroundStyle(.ink)
                Text("community.marketplace.detail").kiraFont(.footnote).foregroundStyle(.inkMuted)
            }
            CommunityRulesLine { readsRules = true }
        }
    }
}
