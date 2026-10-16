/**
 The frame every health-check step shares (KuisPenghasilan and the steps after it): the nav bar
 with only a back button, "Cek Kesehatan · N dari 6" under it, the step's content 20 pt apart, and
 its buttons at the bottom; Kuku may sit on a branch at the lower right, over the scenery.
 */
import Features
import SwiftUI

struct QuizStepLayout<Content: View, Actions: View>: View {
    let step: HealthCheckStep
    let title: LocalizedStringResource
    let flow: OnboardingFlowModel
    var showsMascot = true
    var leaf: OnboardingLeaf?
    @ViewBuilder let content: () -> Content
    @ViewBuilder let actions: () -> Actions
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        OnboardingPage(spacing: KiraSpacing.space5) {
            KiraNavBar(title, leading: .back("onboarding.back") { flow.back() })
            KiraStepProgress(
                current: step.number, total: HealthCheckStep.total,
                label: "onboarding.quiz.progress \(step.number) \(HealthCheckStep.total)"
            )
            .overlay(alignment: .bottomTrailing) {
                if step == .income, !typeSize.isAccessibilitySize { note.offset(y: 3) }
            }
            /** At accessibility sizes the note would cover the label, so it goes under it. */
            if step == .income, typeSize.isAccessibilitySize {
                note.frame(maxWidth: .infinity, alignment: .trailing)
            }
            content()
            Spacer(minLength: 0)
            VStack(spacing: KiraSpacing.space5) { actions() }.onboardingFoot(spacing: KiraSpacing.space5)
        }
        .onboardingBackdrop(leaf: leaf, showsMascot: showsMascot)
    }

    private var note: some View {
        KiraHandNote("onboarding.quiz.note", size: .small, tilt: -3).padding(.trailing, 2)
    }
}

/** "Lewati" (or "Isi Nanti") on the left and "Lanjut" on the right, with the problem above them. */
struct QuizActions: View {
    var skipLabel: LocalizedStringResource = "onboarding.quiz.skip"
    let onSkip: () -> Void
    let onNext: () -> Void

    var body: some View {
        KiraButtonPair(
            secondary: KiraButton(skipLabel, variant: .secondary, action: onSkip),
            primary: KiraButton("onboarding.next", action: onNext))
    }
}

/** One rupiah field of a quiz step: digits only on the number pad, "Rp" before and ",00" after. */
struct QuizAmountField: View {
    let label: LocalizedStringResource
    let hint: LocalizedStringResource
    @Binding var text: String

    var body: some View {
        KiraField(label, text: $text)
            .amount()
            .prefix("onboarding.quiz.currency")
            .suffix("onboarding.quiz.cents")
            .hint(hint)
            .keyboardType(.numberPad)
    }
}
