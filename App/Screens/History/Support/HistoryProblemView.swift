/**
 A screen of the history flow that could not load: the problem's message from the catalog
 (`problem.<CODE>`), the reference to quote for one this app does not know, and Coba Lagi.
 */
import APIClient
import SwiftUI

/** The failed phase of a history screen. */
struct HistoryProblemView: View {
    let problem: AppProblem
    let retry: () -> Void

    var body: some View {
        VStack(spacing: KiraSpacing.space4) {
            KiraIllustration(.umbrella, size: 112)
            Text(LocalizedStringKey(problem.messageKey))
                .font(.body).kiraLineHeight(22, size: 17)
                .foregroundStyle(.ink)
                .multilineTextAlignment(.center)
            if problem.knownCode == nil {
                Text(problem.reference)
                    .kiraFont(.formula)
                    .foregroundStyle(.inkMuted)
                    .textSelection(.enabled)
            }
            KiraButton("history.retry", variant: .secondary) { retry() }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, KiraSpacing.space8)
    }
}
