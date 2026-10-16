/**
 What a Plans screen shows while it loads or when the API refused: a spinner, or the problem's
 message (with its reference when the code is unknown) and Coba Lagi (AGENTS.md Rule 12).
 */
import APIClient
import SwiftUI

struct PlansLoadingView: View {
    var body: some View {
        ProgressView()
            .frame(maxWidth: .infinity, minHeight: 240)
            .accessibilityLabel(Text("plans.loading"))
    }
}

struct PlansProblemView: View {
    let problem: AppProblem
    var retry: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: KiraSpacing.space3) {
            PlansProblemNotice(problem: problem)
            if let retry {
                KiraButton("plans.retry", variant: .secondary, action: retry).block()
            }
        }
    }
}

/** The problem of a refused action, shown where the action is. */
struct PlansProblemNotice: View {
    let problem: AppProblem

    var body: some View {
        VStack(alignment: .leading, spacing: KiraSpacing.space1) {
            KiraNotice(
                .warning, title: "plans.problem.title",
                message: problem.message)
            if problem.knownCode == nil {
                Text(problem.reference)
                    .font(.footnote).foregroundStyle(.inkMuted)
                    .padding(.horizontal, KiraSpacing.space1)
                    .textSelection(.enabled)
            }
        }
    }
}
