/**
 The composition root (AGENTS.md Rule 1): the one place that builds what each screen needs and
 hands it over. The session and the lock keep their secrets in the Keychain. A debug build
 launched with `-KiraGallery [page]` opens the design system gallery instead (the Kira scheme
 lists it, off), and one launched with `-KiraScreen <name>` opens that screen on the preview services
 (App/Launch/ScreenLaunch.swift), for the accessibility audit UI tests.

 Until the integrator builds the generated client (with `AuthMiddleware(tokens: session)`), the
 session cannot reach `POST /auth/refresh` and Lupa PIN runs on its preview service.
 */
import APIClient
import Features
import Foundation
import SwiftUI

@main
struct KiraApp: App {
    @State private var root = KiraApp.makeRoot()

    var body: some Scene {
        WindowGroup {
            #if DEBUG
                if let gallery = DesignSystemGallery(arguments: ProcessInfo.processInfo.arguments) {
                    gallery
                } else if let screen = ScreenLaunch(arguments: ProcessInfo.processInfo.arguments) {
                    screen
                } else {
                    rootView
                }
            #else
                rootView
            #endif
        }
    }

    private var rootView: some View {
        RootView(
            model: root,
            makeUnlock: { [root] in UnlockModel(lock: root.lock, email: root.session.accountEmail) },
            makeRecovery: { [root] in
                root.session.accountEmail.map {
                    PinRecoveryModel(
                        email: $0, service: PreviewPinRecoveryService(), session: root.session, lock: root.lock)
                }
            })
    }

    private static func makeRoot() -> RootModel {
        let vault = lockedDemoVault() ?? KeychainVault()
        /** The integrator replaces this with the generated client's `refreshSession`. */
        let session = SessionStore(vault: vault) { _ in throw AppProblem() }
        return RootModel(session: session, lock: AppLockModel(pins: PinStore(vault: vault), vault: vault))
    }

    /**
     A debug build launched with `-KiraLocked` starts signed in as dinda@email.com with the PIN
     381449, in memory only, so the lock screen and its accessibility audit can be reached.
     */
    private static func lockedDemoVault() -> (any SecretVault)? {
        #if DEBUG
            guard ProcessInfo.processInfo.arguments.contains("-KiraLocked") else { return nil }
            let vault = InMemoryVault([
                .refreshToken: Data("demo-refresh".utf8), .accountEmail: Data("dinda@email.com".utf8),
            ])
            try? PinStore(vault: vault).setPin("381449")
            return vault
        #else
            return nil
        #endif
    }
}
