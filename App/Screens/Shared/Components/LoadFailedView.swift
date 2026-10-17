/**
 A screen that could not load (Beranda, Kira Score, Riwayat and the screens under it): what went
 wrong in the API's words from the catalog, with the reference for a code this app does not know
 (AGENTS.md Rule 12), and "Coba Lagi". The title is optional; History's screens have none. A screen
 whose loaded state has a back or close button passes it as `leading`, so a failed load never traps
 the person: the same outline icon button, top left, named after where it goes.
 */
import APIClient
import SwiftUI

struct LoadFailedView: View {
    /** The way out the screen's loaded state shows. */
    enum Leading {
        /** No way out: a tab's root. */
        case none
        /** The chevron back button, "Kembali ke …". */
        case back(LocalizedStringResource, () -> Void)
        /** The X of a modal screen. */
        case close(LocalizedStringResource, () -> Void)
    }

    var title: LocalizedStringResource?
    var leading: Leading = .none
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
                Text("problem.reference \(problem.reference)").kiraFont(.caption).foregroundStyle(.inkMuted)
            }
            KiraButton("loadFailed.retry", action: retry).icon(.refresh)
        }
        .padding(KiraSpacing.screen)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(alignment: .topLeading) {
            way.padding(.horizontal, KiraSpacing.screen).padding(.top, KiraSpacing.space2)
        }
        .background(.surface)
    }

    @ViewBuilder private var way: some View {
        switch leading {
        case .none: EmptyView()
        case .back(let label, let action): KiraIconButton.back(label, action: action)
        case .close(let label, let action): KiraIconButton.close(label, action: action)
        }
    }
}
