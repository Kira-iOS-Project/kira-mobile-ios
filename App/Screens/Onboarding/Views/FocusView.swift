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
    @Environment(\.dynamicTypeSize) private var typeSize

    init(flow: OnboardingFlowModel) {
        self.flow = flow
        _model = State(initialValue: flow.makeFocusModel())
    }

    var body: some View {
        OnboardingPage {
            KiraNavBar("onboarding.focus.title", leading: .back("onboarding.back") { flow.back() })
            heading
            VStack(spacing: 10) {
                FocusCard(focus: .trackSpending, art: .receipt, model: model)
                FocusCard(focus: .debtFree, art: .cardPaidOff, model: model)
            }
            Text("onboarding.focus.hint").onboardingNote()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, KiraSpacing.space1)
            Spacer(minLength: 0)
            VStack(spacing: KiraSpacing.space2) {
                KiraButton("onboarding.next") { Task { await model.submit() } }
                    .block()
                    .disabled(model.phase.isSubmitting)
                KiraButton("onboarding.focus.unsure", variant: .secondary) { Task { await model.skip() } }.block()
            }
            .onboardingFoot()
        }
        .onboardingBackdrop(leaf: .twig(size: 130, top: 8))
        .problemDialog(model.phase.problem)
    }

    /** "Satu pertanyaan dulu" with its note, and the question. */
    private var heading: some View {
        VStack(alignment: .leading, spacing: 6) {
            /** The note beside the overline; under it at accessibility sizes, so no word breaks. */
            let row =
                typeSize.isAccessibilitySize
                ? AnyLayout(VStackLayout(alignment: .leading, spacing: KiraSpacing.space1))
                : AnyLayout(HStackLayout(spacing: KiraSpacing.space3))
            row {
                Text("onboarding.focus.overline").onboardingOverline()
                if !typeSize.isAccessibilitySize { Spacer(minLength: 0) }
                KiraHandNote("onboarding.focus.note", size: .small)
            }
            .frame(minHeight: 24)
            OnboardingHeading(text: "onboarding.focus.heading", size: 28)
        }
        .padding([.horizontal, .top], KiraSpacing.space1)
    }
}

/** One choice: its picture, title and line, and the round mark that shows it is chosen. */
private struct FocusCard: View {
    let focus: Focus
    let art: KiraIllustrationName
    let model: FocusModel

    private var isSelected: Bool { model.selection == focus }

    var body: some View {
        Button {
            model.selection = focus
        } label: {
            HStack(spacing: KiraSpacing.space3) {
                KiraIllustration(art, size: 68)
                VStack(alignment: .leading, spacing: 3) {
                    Text(focus == .trackSpending ? "onboarding.focus.track" : "onboarding.focus.debt")
                        .font(.headline).kiraLineHeight(22, size: 17)
                    Text(focus == .trackSpending ? "onboarding.focus.track.detail" : "onboarding.focus.debt.detail")
                        .font(.subheadline).kiraLineHeight(20, size: 15).foregroundStyle(.inkMuted)
                }
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
                mark
            }
            .foregroundStyle(.ink)
            /** The board's padding inside its 1 pt (or chosen, 2 pt) border, so 17 pt to the edge. */
            .padding(EdgeInsets(top: 17, leading: 15, bottom: 17, trailing: 17))
            .kiraCard(
                isSelected ? .pandanSoft : .surfaceRaised, border: isSelected ? .pandan : .hairline,
                cornerRadius: KiraRadius.large
            )
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
