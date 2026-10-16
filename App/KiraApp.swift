/**
 The composition root (AGENTS.md Rule 1): the one place that builds what each screen needs and
 hands it over. Screens arrive with their tickets, starting with onboarding. A debug build launched
 with `-KiraGallery [page]` opens the design system gallery instead (the Kira scheme lists it, off).
 */
import SwiftUI

@main
struct KiraApp: App {
    var body: some Scene {
        WindowGroup {
            #if DEBUG
                if let gallery = DesignSystemGallery(arguments: ProcessInfo.processInfo.arguments) {
                    gallery
                } else {
                    RootView()
                }
            #else
                RootView()
            #endif
        }
    }
}
