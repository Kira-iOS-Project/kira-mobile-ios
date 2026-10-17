/**
 Kenali Profil Risikomu (REN-01): the card that starts the risk-profile quiz (REN-06), five questions
 in about three minutes, with the book beside it. The whole card is one button.
 */
import SwiftUI

struct PlanQuizCard: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: KiraSpacing.space3) {
                VStack(alignment: .leading, spacing: KiraSpacing.space1) {
                    Text("plan.quiz.overline").kiraFont(.overline).foregroundStyle(.pandan)
                    Text("plan.quiz.title").kiraFont(.title).foregroundStyle(.ink)
                    Text("plan.quiz.body").font(.subheadline).kiraLineHeight(20, size: 15).foregroundStyle(.inkMuted)
                    HStack(spacing: 6) {
                        KiraIcon(.clock, size: 15)
                        Text("plan.quiz.meta")
                    }
                    .font(.footnote.weight(.medium)).foregroundStyle(.inkMuted)
                    .padding(.top, 6)
                    HStack(spacing: 6) {
                        Text("plan.quiz.start")
                        KiraIcon(.arrowRight, size: 17, weight: .semibold)
                    }
                    .font(.subheadline.weight(.semibold)).foregroundStyle(.pandan)
                    .padding(.top, 10)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                KiraIllustration(.book, size: 88).accessibilityHidden(true)
            }
            .padding(.vertical, 18)
            .padding(.leading, 18)
            .padding(.trailing, KiraSpacing.space4)
            .kiraCard()
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
    }
}
