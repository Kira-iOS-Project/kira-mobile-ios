/**
 The composition root (AGENTS.md Rule 1): the one place that knows the server, builds the
 generated client, the session, the lock and every service, and hands them to the views. The
 session and the lock keep their secrets in the Keychain. A debug build launched with
 `-KiraGallery [page]` opens the design system gallery instead, `-KiraPreviewServices` runs every
 screen on its sample data, `-KiraLocked` starts signed in behind the lock, and `-KiraScreen <name>`
 opens one screen on the preview services (App/Launch/ScreenLaunch.swift) for the audit UI tests.
 */
import APIClient
import Features
import Foundation
import SwiftUI

@main
struct KiraApp: App {
    @State private var app = KiraApp.makeApp()

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
            model: app.root,
            makeUnlock: { [root = app.root] in UnlockModel(lock: root.lock, email: root.session.accountEmail) },
            makeRecovery: { [root = app.root, recovery = app.services.recovery] in
                root.session.accountEmail.map {
                    PinRecoveryModel(email: $0, service: recovery, session: root.session, lock: root.lock)
                }
            }
        )
        .environment(\.appServices, app.services)
        .environment(\.recordComposition, app.record)
    }
}

/** What the root holds: the root model and the services its screens call. */
private struct ComposedApp {
    let root: RootModel
    let services: AppServices
    /** Catat's and Riwayat's services; nil runs them on their preview services (debug builds only). */
    let record: RecordComposition?
}

extension KiraApp {
    /** The API's host; every route already starts with `/api`. The one place the server is named. */
    private static let serverURL = URL(string: "https://api-kira.serenitycode.tech") ?? URL(filePath: "/")

    private static func makeApp() -> ComposedApp {
        let vault = lockedDemoVault() ?? KeychainVault()
        /** `POST /auth/refresh` needs no bearer token, so it goes through a client without the middleware. */
        let publicAPI = KiraAPI(serverURL: serverURL)
        let session = SessionStore(vault: vault) { try await SessionRefresh.refresh($0, with: publicAPI) }
        let api = KiraAPI(serverURL: serverURL, middlewares: [AuthMiddleware(tokens: session)])
        let pins = PinStore(vault: vault)
        let lock = AppLockModel(pins: pins, vault: vault)
        let previews = usesPreviewServices
        let services = previews ? AppServices.preview : .live(api: api, session: session, lock: lock, pins: pins)
        let root = RootModel(session: session, lock: lock) {
            previews ? .ready(hidesBalances: false) : await AccountStage.check(with: api)
        }
        return ComposedApp(root: root, services: services, record: previews ? nil : .live(api: api))
    }

    /** A debug build launched with `-KiraPreviewServices`: every screen on its sample data. */
    private static var usesPreviewServices: Bool {
        #if DEBUG
            ProcessInfo.processInfo.arguments.contains("-KiraPreviewServices")
        #else
            false
        #endif
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
