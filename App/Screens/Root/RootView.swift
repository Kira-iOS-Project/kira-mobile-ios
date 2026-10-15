// The first screen until onboarding replaces it: the app's name and what it helps with. It has no
// state, so it has no screen model yet (AGENTS.md Rule 4 applies from the first screen that does).
import SwiftUI

struct RootView: View {
    var body: some View {
        VStack(spacing: 12) {
            Text("root.title")
                .font(.largeTitle.bold())
                .accessibilityAddTraits(.isHeader)
            Text("root.subtitle")
                .font(.body)
                .multilineTextAlignment(.center)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    RootView()
}
