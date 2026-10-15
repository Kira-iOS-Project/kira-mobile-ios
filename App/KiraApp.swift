// The composition root (AGENTS.md Rule 1): the one place that builds what each screen needs and
// hands it over. Screens arrive with their tickets, starting with onboarding.
import SwiftUI

@main
struct KiraApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
