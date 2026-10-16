/**
 Pilih Fokus (ONB-09): one question and two picture cards, a single choice that sets the first
 Beranda. "Belum Tahu, Lihat-Lihat Dulu" keeps the default and goes on to the health check.
 */
import Domain
import Features
import SwiftUI

struct FocusView: View {
    let flow: OnboardingFlowModel
    @State private var model: FocusModel

    init(flow: OnboardingFlowModel) {
        self.flow = flow
        _model = State(initialValue: flow.makeFocusModel())
    }

    var body: some View {
        OnboardingPage {
            KiraNavBar("onboarding.focus.title", leading: .back("onboarding.back") { flow.back() })
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: KiraSpacing.space3) {
                    Text("onboarding.focus.overline").onboardingOverline()
                    Spacer(minLength: 0)
                    KiraHandNote("onboarding.focus.note", size: .small)
                }
                .frame(minHeight: 24)
                OnboardingHeading(text: "onboarding.focus.heading", size: 28)
            }
            .padding([.horizontal, .top], KiraSpacing.space1)
            VStack(spacing: 10) {
                FocusCard(focus: .trackSpending, art: .receipt, model: model)
                FocusCard(focus: .debtFree, art: .cardPaidOff, model: model)
            }
            Text("onboarding.focus.hint").onboardingNote()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, KiraSpacing.space1)
            Spacer(minLength: 0)
            VStack(spacing: KiraSpacing.space1) {
                if let problem = model.phase.problem { ProblemMessage(problem: problem) }
                KiraButton("onboarding.next") { Task { await model.submit() } }
                    .block()
                    .disabled(model.phase.isSubmitting)
                KiraButton("onboarding.focus.unsure", variant: .quiet, size: .small) { Task { await model.skip() } }
            }
        }
        .onboardingBackdrop(leaf: .twig(size: 130, top: 8))
    }
}

/** One choice: its picture, title and line, and the round mark that shows it is chosen. */
private struct FocusCard: View {
    let focus: Focus
    let art: KiraIllustrationName
    let model: FocusModel

    private var isSelected: Bool { model.selection == focus }

    var body: some View {
        Button { model.selection = focus } label: {
            HStack(spacing: KiraSpacing.space3) {
                KiraIllustration(art, size: 68)
                VStack(alignment: .leading, spacing: 3) {
                    Text(focus == .trackSpending ? "onboarding.focus.track" : "onboarding.focus.debt")
                        .font(.headline).kiraLineHeight(22, size: 17)
                    Text(focus == .trackSpending ? "onboarding.focus.track.detail" : "onboarding.focus.debt.detail")
                        .font(.subheadline).kiraLineHeight(20, size: 15).foregroundStyle(.inkMuted)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                mark
            }
            .foregroundStyle(.ink)
            .padding(EdgeInsets(top: 16, leading: 14, bottom: 16, trailing: 16))
            .kiraCard(isSelected ? .pandanSoft : .surfaceRaised, border: isSelected ? .pandan : .hairline, cornerRadius: KiraRadius.large)
            .overlay {
                RoundedRectangle(cornerRadius: KiraRadius.large, style: .continuous)
                    .strokeBorder(isSelected ? Color.pandan : .clear, lineWidth: 2)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }

    @ViewBuilder private var mark: some View {
        if isSelected {
            KiraIcon(.check, size: 16, weight: .heavy)
                .foregroundStyle(.onPandan)
                .frame(width: 26, height: 26)
                .background(.pandan, in: Circle())
        } else {
            Circle().strokeBorder(.lineStrong, lineWidth: 1.5).frame(width: 26, height: 26)
        }
    }
}
