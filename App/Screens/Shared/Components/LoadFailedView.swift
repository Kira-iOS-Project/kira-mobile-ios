/**
 A screen that could not load (Beranda, Kira Score, Riwayat and the screens under it): what went
 wrong in the API's words from the catalog, with the reference for a code this app does not know
 (AGENTS.md Rule 12), and "Coba Lagi". The title is optional; History's screens have none.
 */
import APIClient
import SwiftUI

struct LoadFailedView: View {
    var title: LocalizedStringResource?
    let problem: AppProblem
    let retry: () -> Void

    var body: some View {
        VStack(spacing: KiraSpacing.space4) {
            KiraIllustration(.care, size: 112)
            if let title {
                Text(title).kiraFont(.title).foregroundStyle(.ink).multilineTextAlignment(.center)
                    .accessibilityAddTraits(.isHeader)
            }
            Text(problem.message).kiraFont(.callout).foregroundStyle(.inkMuted)
                .multilineTextAlignment(.center)
            if problem.showsReference {
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
