import APIClient
import Domain
import Features
import SwiftUI

struct WalletCreateSheet: View {
    @Bindable var model: WalletCreateModel
    let cancel: () -> Void
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: KiraSpacing.space4) {
                typePicker
                nameField
                amountField
                KiraNotice(.safe, message: "wallet.create.privacy")
                if case .failed(let problem) = model.phase { WalletCreateProblem(problem: problem) }
            }
        }
        .scrollBounceBehavior(.basedOnSize)
        .safeAreaInset(edge: .bottom, spacing: 0) { actions.padding(.bottom, KiraSpacing.space2) }
    }

    private var typePicker: some View {
        VStack(alignment: .leading, spacing: KiraSpacing.space2) {
            Text("wallet.create.type").font(.footnote.weight(.semibold)).foregroundStyle(.inkMuted)
            KiraFlowRow {
                ForEach(WalletType.selectableCases, id: \.self) { type in
                    KiraChip(type.titleKey, isSelected: model.type == type, leading: .category(type.category)) {
                        model.type = type
                    }
                }
            }
        }
    }

    private var nameField: some View {
        KiraField("wallet.create.name", text: $model.name, prompt: "wallet.create.name.prompt")
            .hint("wallet.create.name.hint")
            .error(
                model.showsFieldErrors && model.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    ? "wallet.create.name.required" : nil)
    }

    private var amountField: some View {
        KiraField(model.type.amountLabelKey, text: $model.amountText, prompt: "wallet.create.amount.prompt")
            .amount().prefix("wallet.currency").suffix("wallet.cents")
            .error(
                model.showsFieldErrors && AmountInput.value(of: model.amountText) == nil
                    ? "wallet.create.amount.required" : nil
            )
            .keyboardType(.numberPad)
    }

    @ViewBuilder private var actions: some View {
        let secondary = KiraButton("wallet.create.cancel", variant: .secondary, action: cancel)
        let primary = KiraButton("wallet.create.save") { Task { await model.save() } }
        if typeSize.isAccessibilitySize {
            KiraButtonPair(secondary: secondary, primary: primary).disabled(model.isSaving)
        } else {
            WeightedRow(weights: [1, 1.3], spacing: KiraSpacing.space2) {
                secondary.block()
                primary.block()
            }.disabled(model.isSaving)
        }
    }
}

private struct WalletCreateProblem: View {
    let problem: AppProblem

    var body: some View {
        VStack(alignment: .leading, spacing: KiraSpacing.space1) {
            KiraNotice(.warning, title: "wallet.create.failed.title", message: problem.message)
            if problem.knownCode == nil { Text(problem.reference).font(.footnote).foregroundStyle(.inkMuted) }
        }
    }
}
