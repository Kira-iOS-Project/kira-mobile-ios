/**
 A screen that could not load: what went wrong in the API's words from the catalog (with the
 reference for a code this app does not know, AGENTS.md Rule 12) and "Coba Lagi".
 */
import APIClient
import SwiftUI

struct LoadFailedView: View {
    let title: LocalizedStringResource
    let problem: AppProblem
    let retry: () -> Void

    var body: some View {
        VStack(spacing: KiraSpacing.space4) {
            KiraIllustration(.care, size: 112)
            Text(title).kiraFont(.title).foregroundStyle(.ink).multilineTextAlignment(.center)
                .accessibilityAddTraits(.isHeader)
            Text(LocalizedStringKey(problem.messageKey)).kiraFont(.callout).foregroundStyle(.inkMuted)
                .multilineTextAlignment(.center)
            if problem.knownCode == nil {
                /** The reference is data a person quotes to support, shown as is. */
                Text(problem.reference).kiraFont(.caption).foregroundStyle(.inkMuted)
            }
            KiraButton("loadFailed.retry", action: retry).icon(.refresh)
        }
        .padding(KiraSpacing.screen)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.surface)
    }
}
