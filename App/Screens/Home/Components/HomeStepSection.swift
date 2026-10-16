/**
 "Langkah Berikutnya": the engine's first step on a NextStepCard with its estimated effect; "Nanti
 Saja" puts it away until Beranda loads again.
 */
import Domain
import Features
import SwiftUI

struct HomeStepSection: View {
    let step: ScoreStep
    let home: HomeOverview
    let model: HomeModel
    let onOpen: (AppRoute) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            KiraSectionTitle("home.step.title", trailing: .note(note))
            card
        }
    }

    /** The one handwritten note of Beranda, anchored to this title. */
    private var note: LocalizedStringResource {
        if home.variant == .debtPlan { return "home.step.noteDebt" }
        return "home.step.note"
    }

    private var card: KiraNextStepCard {
        var card = KiraNextStepCard(
            step.title, message: step.message(masked: model.isMasked), primaryLabel: step.primaryLabel,
            onPrimary: { onOpen(step.route) }, onSecondary: { model.dismissStep() }
        )
        .eyebrow("home.step.eyebrow")
        .illustration(step.illustration)
        if let position = home.stepPosition {
            card = card.meta("home.step.position \(position.index) \(position.total)")
        }
        if let score = home.score, step.estimatedGain > 0 {
            card = card.impact("home.step.impact \(score.score) \(score.score + step.estimatedGain)")
        }
        return card
    }
}
