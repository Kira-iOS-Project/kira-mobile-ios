/**
 Beranda (BRD-01, BRD-02, BRD-03), the home tab's root: the variant the API chose, loaded through
 `HomeService`. Links leave through `onOpen`; the root lays the dock over it.
 */
import APIClient
import Domain
import Features
import SwiftUI

struct HomeScreen: View {
    @State private var model: HomeModel
    private let onOpen: (AppRoute) -> Void

    init(service: any HomeService, onOpen: @escaping (AppRoute) -> Void) {
        _model = State(initialValue: HomeModel(service: service))
        self.onOpen = onOpen
    }

    var body: some View {
        Group {
            switch model.phase {
            case .loading:
                HomeContent(home: .placeholder, model: model) { _ in }
                    .redacted(reason: .placeholder)
                    .disabled(true)
            case .loaded(let home):
                HomeContent(home: home, model: model, onOpen: onOpen)
            case .empty:
                LoadFailedView(title: "home.failed", problem: AppProblem()) { reload() }
            case .failed(let problem):
                LoadFailedView(title: "home.failed", problem: problem) { reload() }
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

/** The loaded Beranda: the header, then the sections of its variant. */
private struct HomeContent: View {
    let home: HomeOverview
    let model: HomeModel
    let onOpen: (AppRoute) -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: KiraSpacing.space4) {
                HomeHeader(home: home, dayPart: model.dayPart, onOpen: onOpen)
                switch home.variant {
                case .firstSteps: HomeFirstSteps(home: home, onOpen: onOpen)
                case .overview: HomeOverviewSections(home: home, model: model, onOpen: onOpen)
                case .debtPlan: HomeDebtPlanSections(home: home, model: model, onOpen: onOpen)
                }
                if let score = home.score {
                    HomeScoreCard(score: score) { onOpen(.score) }
                }
            }
            .padding(.horizontal, KiraSpacing.screen)
            .padding(.bottom, KiraSpacing.space10)
            .background(alignment: .topTrailing) {
                KiraLeaf(.twig, tone: .soft, size: 150, isFlipped: true)
                    .offset(x: 34, y: -24)
                    .accessibilityHidden(true)
            }
        }
        .refreshable { await model.load() }
        .kiraScrollEdges()
    }
}

/** BRD-01's sections between the header and the score: the money left, the step, the weekly summary. */
private struct HomeOverviewSections: View {
    let home: HomeOverview
    let model: HomeModel
    let onOpen: (AppRoute) -> Void

    var body: some View {
        if let money = home.money {
            HomeMoneyCard(money: money, period: home.period, model: model) { onOpen(.unavailable(.budget)) }
        }
        if let step = model.visibleStep {
            HomeStepSection(step: step, home: home, model: model, onOpen: onOpen)
        }
        if let week = home.weeklySummary {
            HomeWeeklyCard(range: week) { onOpen(.unavailable(.weeklySummary)) }
        }
    }
}
