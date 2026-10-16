/**
 Cek Kesehatan · Tanggungan dan Proteksi (ONB-12): dependents and marital status (one choice
 each), which set the emergency-fund target, and the protections held (several; "Belum Ada"
 clears them). "Lihat Hasilku" runs the score engine on the server; no AI.
 */
import Domain
import Features
import SwiftUI

struct ProtectionStepView: View {
    let flow: OnboardingFlowModel
    let model: HealthCheckModel

    var body: some View {
        QuizStepLayout(step: .protection, title: "onboarding.protection.title", flow: flow, showsMascot: false) {
            ProtectionChoices(answers: model.protection)
            VStack(spacing: KiraSpacing.space1) {
                KiraIllustration(.umbrella, size: 120)
                KiraHandNote("onboarding.protection.note")
            }
            .frame(maxWidth: .infinity)
            .padding(.top, KiraSpacing.space2)
        } actions: {
            VStack(spacing: KiraSpacing.space2) {
                if let problem = model.phase.problem { ProblemMessage(problem: problem) }
                KiraButton("onboarding.protection.submit") { Task { await model.submit() } }
                    .block()
                    .disabled(model.phase.isSubmitting)
            }
        }
    }
}

private struct ProtectionChoices: View {
    @Bindable var answers: ProtectionAnswersModel
    private let dependentChoices: [LocalizedStringResource] = [
        "onboarding.protection.dependents.none", "onboarding.protection.dependents.one",
        "onboarding.protection.dependents.two", "onboarding.protection.dependents.many",
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: KiraSpacing.space5) {
            VStack(alignment: .leading, spacing: KiraSpacing.space3) {
                VStack(alignment: .leading, spacing: KiraSpacing.space2) {
                    QuizQuestion(text: "onboarding.protection.question").padding(.horizontal, -KiraSpacing.space1)
                    Text("onboarding.protection.lead").font(.subheadline).kiraLineHeight(21, size: 15)
                        .foregroundStyle(.inkMuted)
                }
                .padding(.horizontal, KiraSpacing.space1)
                KiraFlowRow {
                    ForEach(dependentChoices.indices, id: \.self) { count in
                        KiraChip(dependentChoices[count], isSelected: answers.dependents == count) { answers.dependents = count }
                    }
                }
            }
            ChipSection(title: "onboarding.protection.marital") {
                KiraChip("onboarding.protection.single", isSelected: answers.maritalStatus == .single) { answers.maritalStatus = .single }
                KiraChip("onboarding.protection.married", isSelected: answers.maritalStatus == .married) { answers.maritalStatus = .married }
            }
            ChipSection(title: "onboarding.protection.cover") {
                ForEach(Protection.allCases, id: \.self) { protection in
                    KiraChip(protection.title, isSelected: answers.protections.contains(protection)) { answers.toggle(protection) }
                }
                KiraChip("onboarding.protection.none", isSelected: answers.hasNone) { answers.toggleNone() }
            }
        }
    }
}

/** A headline with a small leaf, and its chips. */
private struct ChipSection<Chips: View>: View {
    let title: LocalizedStringResource
    @ViewBuilder let chips: () -> Chips

    var body: some View {
        VStack(alignment: .leading, spacing: KiraSpacing.space3) {
            HStack(spacing: KiraSpacing.space2) {
                KiraLeaf(.single, size: 18)
                Text(title).kiraFont(.headline).foregroundStyle(.ink).accessibilityAddTraits(.isHeader)
            }
            .padding(.horizontal, KiraSpacing.space1)
            KiraFlowRow { chips() }
        }
    }
}

extension Protection {
    /** The chip's name ("BPJS Kesehatan"). */
    fileprivate var title: LocalizedStringResource {
        switch self {
        case .bpjsHealth: "onboarding.protection.bpjsHealth"
        case .bpjsEmployment: "onboarding.protection.bpjsEmployment"
        case .lifeInsurance: "onboarding.protection.life"
        case .privateHealth: "onboarding.protection.privateHealth"
        }
    }
}
