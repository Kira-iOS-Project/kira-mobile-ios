import Domain
/**
 Traktir Kira (AKN-07f, AKN-07g; boards TraktirKira, TraktirKiraDialogBerhasil): 1, 3 or 6 months
 of Kira Plus for Beasiswa Kira, the total from Kira Plus's monthly price, simulated. Selesai
 closes the page.
 */
import Features
import SwiftUI

struct TreatView: View {
    @State private var model: TreatModel
    @Environment(\.dismiss) private var dismiss

    init(service: any PlansService) {
        _model = State(initialValue: TreatModel(service: service))
    }

    var body: some View {
        PlansScreenFrame {
            KiraNavBar("treat.title", leading: .back("treat.back") { dismiss() })
            PlansHeader("treat.title", subtitle: "treat.lede")
            VStack(alignment: .leading, spacing: 6) {
                Text("treat.length").font(.footnote.weight(.semibold)).kiraLineHeight(18, size: 13)
                    .foregroundStyle(.inkMuted).padding(.horizontal, KiraSpacing.space1)
                    .accessibilityHidden(true)
                KiraSegmented("treat.length.label", options: monthOptions, selection: $model.months)
            }
            content
        }
        .task { await model.load() }
        .kiraDialog(isPresented: showsThanks) {
            KiraDialog(
                "treat.success.title", message: "treat.success.body", art: .illustration(.care),
                primary: KiraButton("treat.done") { dismiss() })
        }
    }

    private var monthOptions: [KiraSegmented<Int>.Option] {
        [
            .init(id: 1, title: "treat.months.one"), .init(id: 3, title: "treat.months.three"),
            .init(id: 6, title: "treat.months.six"),
        ]
    }

    private var showsThanks: Binding<Bool> {
        Binding(get: { model.gift != nil }, set: { if !$0 { model.gift = nil } })
    }

    @ViewBuilder private var content: some View {
        switch model.phase {
        case .loading, .empty:
            PlansLoadingView()
        case .failed(let problem):
            PlansProblemView(problem: problem) { Task { await model.load() } }
        case .loaded:
            HStack(spacing: KiraSpacing.space3) {
                Text("treat.total").font(.headline).kiraLineHeight(22, size: 17).foregroundStyle(.ink)
                    .frame(maxWidth: .infinity, alignment: .leading)
                KiraAmount(Decimal(model.total))
            }
            .padding(KiraSpacing.space4)
            .kiraCard()
            .accessibilityElement(children: .combine)
            KiraNotice(.education, title: "treat.where.title", message: "treat.where.body")
            KiraNotice(.info, title: "plans.prototype", message: "treat.prototype")
            if let problem = model.sendProblem { PlansProblemNotice(problem: problem) }
            PlansButtonRow(
                secondary: KiraButton("treat.cancel", variant: .secondary, size: .small) { dismiss() },
                primary: KiraButton("treat.send \(Decimal(model.total), format: .rupiah)", size: .small) {
                    Task { await model.send() }
                }
            )
            .disabled(model.isSending)
        }
    }
}
