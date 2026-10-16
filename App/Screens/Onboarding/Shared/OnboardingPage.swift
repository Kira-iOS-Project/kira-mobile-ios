/**
 A board's page: its content at the full height of the screen, with the screen margin, so a
 `Spacer` pushes the main button to the bottom; on a short screen or at large text sizes it
 scrolls instead of squeezing.
 */
import APIClient
import SwiftUI

struct OnboardingPage<Content: View>: View {
    var spacing: CGFloat = KiraSpacing.space4
    @ViewBuilder let content: () -> Content

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(spacing: spacing) { content() }
                    .padding(.horizontal, KiraSpacing.screen)
                    .padding(.top, KiraSpacing.space1)
                    .padding(.bottom, KiraSpacing.space2)
                    .frame(minHeight: proxy.size.height, alignment: .top)
            }
            .scrollBounceBehavior(.basedOnSize)
        }
        .kiraScrollEdges()
        .toolbar(.hidden, for: .navigationBar)
    }
}

/** The API's problem as a sentence, with the reference to quote when the app does not know the code. */
struct ProblemMessage: View {
    let problem: AppProblem

    var body: some View {
        VStack(spacing: 2) {
            Text(LocalizedStringKey(problem.messageKey))
            if problem.knownCode == nil {
                Text(problem.reference).font(.caption.monospaced())
            }
        }
        .font(.footnote).kiraLineHeight(18, size: 13)
        .foregroundStyle(.vulnerable)
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
    }
}
