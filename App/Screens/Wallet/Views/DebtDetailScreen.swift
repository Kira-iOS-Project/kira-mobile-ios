/**
 UNG-03, Detail Utang (board DetailUtang, "Paylater A"): the debt's name with "Akun utang", its
 remaining amount and how much of the total is paid, Rincian (the monthly instalment, the next due
 date with the days left), Langkah Berikutnya from the payoff engine, Riwayat Pembayaran, and the
 Panduan SLIK card. A failed load shows its problem with Coba Lagi.
 */
import Domain
import Features
import SwiftUI

struct DebtDetailScreen: View {
    private let onOpen: (AppRoute) -> Void
    @State private var model: DebtDetailModel
    @Environment(\.dismiss) private var dismiss

    init(id: String, service: any DebtDetailService, onOpen: @escaping (AppRoute) -> Void) {
        self.onOpen = onOpen
        _model = State(initialValue: DebtDetailModel(id: id, service: service))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: KiraSpacing.space4) {
                KiraNavBar(title, subtitle: "debt.detail.subtitle", leading: .back("debt.detail.back") { dismiss() }) {
                    KiraHelpButton(.icon) { onOpen(.care) }
                }
                content
            }
            .padding(.horizontal, KiraSpacing.screen)
            .padding(.top, KiraSpacing.space2)
            .padding(.bottom, KiraSpacing.space2)
            .background(alignment: .topTrailing) {
                KiraLeaf(.twig, tone: .soft, size: 150, isFlipped: true).offset(x: 36, y: -22).accessibilityHidden(true)
            }
        }
        .background(.surface)
        .kiraScrollEdges()
        .toolbar(.hidden, for: .navigationBar)
        .task { await model.load() }
    }

    private var title: LocalizedStringResource {
        model.phase.value.map { "debt.detail.title \($0.name)" } ?? "debt.detail.loading"
    }

    @ViewBuilder private var content: some View {
        switch model.phase {
        case .loading:
            ProgressView().frame(maxWidth: .infinity).padding(.vertical, KiraSpacing.space8)
        case .empty:
            EmptyView()
        case .loaded(let debt):
            DebtSummaryCard(debt: debt)
            DebtFacts(debt: debt, today: CalendarDay(.now))
            if let step = debt.nextStep {
                DebtNextStepSection(debt: debt, step: step, onOpen: onOpen)
            }
            if !debt.payments.isEmpty { DebtPaymentHistory(debt: debt) }
            KiraTapCard(
                illustration: .shield, label: Text("debt.detail.slik.label"),
                action: { onOpen(.unavailable(.creditReport)) }
            ) {
                Text("debt.detail.slik.eyebrow").kiraFont(.overline).foregroundStyle(.pandan)
                Text("debt.detail.slik.title").font(.body.weight(.semibold)).kiraLineHeight(22, size: 17)
                Text("debt.detail.slik.body").font(.footnote).kiraLineHeight(18, size: 13).foregroundStyle(.inkMuted)
            }
        case .failed(let problem):
            LoadFailedView(problem: problem) { Task { await model.load() } }
        }
    }
}
