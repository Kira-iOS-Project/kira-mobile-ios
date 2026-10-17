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

extension View {
    /**
     The API's problem in a dialog, never as a line under the form (the owner's choice, 2026-10-17):
     its sentence, or the generic one with the reference to quote when the app does not know the
     code, and Tutup. Each new failure shows it again; Tutup leaves the form as it is.
     */
    func problemDialog(_ problem: AppProblem?, title: LocalizedStringResource = "problem.dialog.title") -> some View {
        modifier(ProblemDialog(problem: problem, title: title))
    }
}

private struct ProblemDialog: ViewModifier {
    let problem: AppProblem?
    let title: LocalizedStringResource
    @State private var shown: AppProblem?
    @State private var isPresented = false

    func body(content: Content) -> some View {
        content
            .onChange(of: problem, initial: true) { _, problem in
                if let problem { shown = problem }
                isPresented = problem != nil
            }
            .kiraDialog(isPresented: $isPresented) {
                KiraDialog(
                    title, message: (shown ?? AppProblem()).failureMessage, art: .illustration(.umbrella),
                    primary: KiraButton("ds.close") {})
            }
    }
}
