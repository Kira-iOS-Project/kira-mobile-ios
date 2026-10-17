/** Detail Utang (KIR-37): balance, installment progress, simulated score, history and payment. */
import APIClient
import Domain
import Features
import SwiftUI

struct DebtDetailScreen: View {
    @State private var model: DebtDetailModel
    @State private var isRecordingPayment = false
    private let onOpenHelp: () -> Void
    private let onOpenSLIK: () -> Void
    private let onDebtUpdated: (DebtDetail) -> Void
    @Environment(\.dismiss) private var dismiss

    init(
        id: String, service: any WalletService, onOpenHelp: @escaping () -> Void = {},
        onOpenSLIK: @escaping () -> Void = {}, onDebtUpdated: @escaping (DebtDetail) -> Void = { _ in }
    ) {
        self.onOpenHelp = onOpenHelp
        self.onOpenSLIK = onOpenSLIK
        self.onDebtUpdated = onDebtUpdated
        _model = State(initialValue: DebtDetailModel(id: id, service: service))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: KiraSpacing.space4) {
                header
                content
            }
            .padding(.horizontal, KiraSpacing.screen)
            .padding(.top, KiraSpacing.space2)
            .padding(.bottom, KiraSpacing.space10)
            .background(alignment: .topTrailing) {
                KiraLeaf(.twig, tone: .soft, size: 150, isFlipped: true).offset(x: 52, y: -22)
            }
        }
        .background(.surface)
        .kiraScrollEdges()
        .toolbar(.hidden, for: .navigationBar)
        .task { await model.load() }
        .onChange(of: model.paymentSucceeded) { _, succeeded in
            guard succeeded, let detail = model.phase.value else { return }
            onDebtUpdated(detail)
            isRecordingPayment = false
        }
        .kiraSheet(isPresented: $isRecordingPayment, title: "wallet.payment.title") {
            DebtPaymentSheet(model: model) { isRecordingPayment = false }
        }
    }

    private var header: some View {
        KiraNavBar("wallet.debt.title", leading: .back("wallet.back") { dismiss() }) {
            KiraHelpButton(.icon, action: onOpenHelp)
        }
    }

    @ViewBuilder private var content: some View {
        switch model.phase {
        case .loading: DebtLoadingContent()
        case .empty: Text("wallet.debt.empty").font(.body).foregroundStyle(.inkMuted)
        case .loaded(let detail):
            DebtDetailContent(detail: detail, onPay: openPayment, onOpenSLIK: onOpenSLIK)
        case .failed(let problem):
            LoadFailedView(title: "wallet.debt.failed", problem: problem) { Task { await model.load() } }
        }
    }

    private func openPayment() {
        model.resetPaymentForm()
        isRecordingPayment = true
    }
}

private struct DebtLoadingContent: View {
    var body: some View {
        DebtDetailContent(detail: WalletPreviewData.debt, onPay: {}, onOpenSLIK: {})
            .redacted(reason: .placeholder).disabled(true)
    }
}
