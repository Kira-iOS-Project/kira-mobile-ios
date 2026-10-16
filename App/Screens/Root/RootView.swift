/**
 The root (ONB-01 onwards): the splash while Kira starts, onboarding for a signed-out person, the
 lock screen when a PIN is set, then the tabs. It reports the scene phase to the lock, which locks
 after the auto-lock interval and blurs Kira in the app switcher.
 */
import Features
import SwiftUI

struct RootView: View {
    let model: RootModel
    /** Builds the lock screen's model for the current account. */
    let makeUnlock: () -> UnlockModel
    /** Builds Lupa PIN's model, or nil when the account's email is unknown. */
    let makeRecovery: () -> PinRecoveryModel?
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            Group {
                switch model.stage {
                case .splash: SplashView()
                case .onboarding:
                    OnboardingSlot(start: model.onboardingStart) { outcome in
                        Task { await model.finishOnboarding(outcome) }
                    }
                    .id(model.onboardingStart)
                case .locked: LockHost(make: makeUnlock, makeRecovery: makeRecovery)
                case .main: MainShell(navigation: model.navigation)
                }
            }
            .transition(.opacity)
        }
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.35), value: model.stage)
        .blur(radius: model.lock.isObscured ? 24 : 0)
        .overlay { if model.lock.isObscured { PrivacyCover() } }
        .environment(\.endSession, EndSessionAction { Task { await model.endSession() } })
        .task { await model.start() }
        .onChange(of: scenePhase, initial: true) { _, phase in
            model.lock.scenePresenceChanged(to: ScenePresence(phase))
        }
    }
}

/** Keeps one lock-screen model while the lock shows, so a redraw never clears the dots. */
private struct LockHost: View {
    @State private var model: UnlockModel
    let makeRecovery: () -> PinRecoveryModel?

    init(make: () -> UnlockModel, makeRecovery: @escaping () -> PinRecoveryModel?) {
        _model = State(initialValue: make())
        self.makeRecovery = makeRecovery
    }

    var body: some View {
        LockScreen(model: model, makeRecovery: makeRecovery)
    }
}

extension ScenePresence {
    /** The lock's view of SwiftUI's scene phase. */
    init(_ phase: ScenePhase) {
        switch phase {
        case .active: self = .active
        case .background: self = .background
        default: self = .inactive
        }
    }
}
