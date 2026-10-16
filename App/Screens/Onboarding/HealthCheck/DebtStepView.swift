/**
 Cek Kesehatan · Utang (ONB-11): debt kinds as picture chips, several allowed ("Tidak Ada" clears
 them), a row per debt with what is left and the monthly instalment, "Tambah Utang Lain", and the
 promise that Kira never reads SLIK. A row or a new chip opens Tambah Rincian Utang (ONB-11b).
 */
import Domain
import Features
import SwiftUI

struct DebtStepView: View {
    let flow: OnboardingFlowModel
    let model: HealthCheckModel

    var body: some View {
        QuizStepLayout(
            step: .debts, title: "onboarding.debt.title", flow: flow, showsMascot: false,
            leaf: .twig(size: 130, top: 150)
        ) {
            VStack(alignment: .leading, spacing: KiraSpacing.space2) {
                QuizQuestion(text: "onboarding.debt.question").padding(.horizontal, -KiraSpacing.space1)
                Text("onboarding.debt.lead").font(.subheadline).kiraLineHeight(21, size: 15).foregroundStyle(.inkMuted)
            }
            .padding(.horizontal, KiraSpacing.space1)
            DebtChips(debts: model.debts)
            DebtRows(debts: model.debts)
            KiraNotice(.privacy, message: "onboarding.debt.notice")
        } actions: {
            QuizActions(skipLabel: "onboarding.quiz.later") {
                model.skip(.debts)
                flow.next(after: .debts)
            } onNext: {
                flow.next(after: .debts)
            }
        }
        .kiraSheet(
            isPresented: Bindable(model.debts).isFormPresented, title: "onboarding.debt.sheet.title",
            subtitle: "onboarding.debt.sheet.subtitle"
        ) {
            DebtFormSheet(debts: model.debts)
        }
    }
}

/** "Boleh pilih lebih dari satu": a chip per kind, then "Tidak Ada". */
private struct DebtChips: View {
    let debts: DebtAnswersModel

    var body: some View {
        VStack(alignment: .leading, spacing: KiraSpacing.space2) {
            Text("onboarding.debt.many").font(.footnote.weight(.semibold)).kiraLineHeight(18, size: 13)
                .foregroundStyle(.inkMuted).padding(.horizontal, KiraSpacing.space1)
            KiraFlowRow {
                ForEach(DebtKind.allCases, id: \.self) { kind in
                    KiraChip(kind.title, isSelected: debts.isSelected(kind), leading: .category(kind.category)) {
                        debts.toggle(kind)
                    }
                }
                KiraChip("onboarding.debt.none", isSelected: debts.hasNoDebts) { debts.toggleNone() }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .contain)
        .accessibilityLabel(Text("onboarding.debt.kinds"))
    }
}

/** "Rinciannya": each debt with what is left and its instalment, and "Tambah Utang Lain". */
private struct DebtRows: View {
    let debts: DebtAnswersModel

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if !debts.entries.isEmpty {
                KiraListGroup("onboarding.debt.details") {
                    ForEach(debts.entries) { entry in
                        KiraListRow(Text(entry.name), leading: .category(entry.kind.category), trailing: .chevron) {
                            debts.edit(entry)
                        } extra: {
                            Text(
                                "onboarding.debt.instalment \(Text(Decimal(entry.monthlyInstalment), format: .rupiah))"
                            )
                            .onboardingNote()
                        }
                        .subtitle(subtitle(for: entry))
                        .amount(KiraAmount(Decimal(entry.remaining)))
                    }
                }
            }
            KiraButton("onboarding.debt.add", variant: .quiet, size: .small) { debts.add() }.icon(.plus)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func subtitle(for entry: DebtEntry) -> Text {
        guard let months = entry.remainingTenorMonths else { return Text("onboarding.debt.remaining") }
        return Text("onboarding.debt.remainingFor \(months)")
    }
}
