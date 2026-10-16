/**
 Rencana Pelunasan (SKR-03; the formula open is SKR-03b, the Avalanche method SKR-03c): the method,
 the extra payment, the order the plan pays in and what it costs. One screen: changing the method
 or the extra payment asks the API again and the same page answers. Pushed from Beranda and from
 the score's steps.
 */
import APIClient
import Domain
import Features
import SwiftUI

struct PayoffScreen: View {
    @State private var model: PayoffModel
    private let onOpen: (AppRoute) -> Void
    @Environment(\.dismiss) private var dismiss

    init(service: any PayoffService, onOpen: @escaping (AppRoute) -> Void) {
        _model = State(initialValue: PayoffModel(service: service))
        self.onOpen = onOpen
    }

    var body: some View {
        Group {
            switch model.phase {
            case .loading:
                PayoffContent(model: model, simulation: .sample, onOpen: { _ in }, onBack: {})
                    .redacted(reason: .placeholder)
                    .disabled(true)
            case .loaded(let simulation):
                PayoffContent(model: model, simulation: simulation, onOpen: onOpen) { dismiss() }
            case .empty:
                PayoffEmptyView { dismiss() }
            case .failed(let problem):
                LoadFailedView(title: "payoff.failed", problem: problem) { Task { await model.load() } }
            }
        }
        .background(.surface)
        .toolbar(.hidden, for: .navigationBar)
        .task { await model.load() }
    }
}

/** The loaded plan, top to bottom as the boards lay it. */
private struct PayoffContent: View {
    let model: PayoffModel
    let simulation: PayoffSimulation
    let onOpen: (AppRoute) -> Void
    let onBack: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: KiraSpacing.space5) {
                PayoffHeader(onOpen: onOpen, onBack: onBack)
                PayoffControls(model: model, maximum: simulation.maxExtraPayment)
                if let problem = model.recalculationProblem {
                    KiraNotice(.warning, title: "payoff.recalc.failed", message: problem.message)
                }
                PayoffHowAccordion(model: model, method: simulation.method)
                PayoffResult(simulation: simulation)
                    .opacity(model.isRecalculating ? 0.5 : 1)
            }
            .padding(.horizontal, KiraSpacing.screen)
            .padding(.top, 3)
            .padding(.bottom, KiraSpacing.space10)
        }
        .kiraScrollEdges()
    }
}

/** The back button and Kira Peduli, the title and what the page does. */
private struct PayoffHeader: View {
    let onOpen: (AppRoute) -> Void
    let onBack: () -> Void
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        VStack(alignment: .leading, spacing: KiraSpacing.space1) {
            HStack {
                KiraIconButton.back("payoff.back", action: onBack)
                Spacer(minLength: KiraSpacing.space2)
                KiraHelpButton { onOpen(.unavailable(.care)) }
                    /** At accessibility sizes it wraps rather than widen the page. */
                    .fixedSize(horizontal: !typeSize.isAccessibilitySize, vertical: true)
            }
            .frame(minHeight: KiraSize.tap)
            Text("payoff.title").kiraFont(.largeTitle).foregroundStyle(.ink).accessibilityAddTraits(.isHeader)
            Text("payoff.subtitle")
                .font(.footnote.weight(.medium)).kiraLineHeight(18, size: 13).foregroundStyle(.inkMuted)
        }
        .padding(.bottom, KiraSpacing.space3)
    }
}

/** Before any consumer debt: nothing to plan, and the way back. */
private struct PayoffEmptyView: View {
    let onBack: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: KiraSpacing.space4) {
            KiraIconButton.back("payoff.back", action: onBack)
            Spacer()
            VStack(spacing: KiraSpacing.space3) {
                KiraIllustration(.sprout, size: 128)
                Text("payoff.empty.title").kiraFont(.title).foregroundStyle(.ink).accessibilityAddTraits(.isHeader)
                Text("payoff.empty.body").kiraFont(.callout).foregroundStyle(.inkMuted)
            }
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            Spacer()
        }
        .padding(KiraSpacing.screen)
    }
}
