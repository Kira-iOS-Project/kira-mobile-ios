/**
 A board's page: its content at the full height of the screen, with the screen margin and the last
 button right on the home indicator's inset as on the boards, so a `Spacer` pushes the main button
 to the bottom; on a short screen or at large text sizes it scrolls instead of squeezing.
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
                    /** The boards' 62 pt from the top of the screen. */
                    .padding(.top, 62 - 59)
                    .frame(minHeight: proxy.size.height, alignment: .top)
            }
            .scrollBounceBehavior(.basedOnSize)
        }
        .kiraScrollEdges()
        .toolbar(.hidden, for: .navigationBar)
    }
}

extension View {
    /**
     The block a board pushes to the bottom (`margin-top: auto`), after a `Spacer`: when the page
     scrolls, its gap above stays the board's one `spacing`, not the two around the spacer.
     */
    func onboardingFoot(spacing: CGFloat = KiraSpacing.space4) -> some View {
        padding(.top, -spacing)
    }
}

/** The API's problem as a sentence, with the reference to quote when the app does not know the code. */
struct ProblemMessage: View {
    let problem: AppProblem

    var body: some View {
        VStack(spacing: 2) {
            Text(problem.message)
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
