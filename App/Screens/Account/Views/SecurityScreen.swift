/**
 Keamanan (AKN-03, canvas Keamanan): the PIN lock (turning it off asks for the PIN first), Ganti
 PIN, Kunci Otomatis (a sheet: Segera, 1 menit, 5 menit), Sembunyikan Saldo saat Membuka and the
 blurred app switcher, under the promise that Kira never asks for a bank PIN.
 */
import Domain
import Features
import SwiftUI

/** The Keamanan screen, opened from Profil. */
struct SecurityScreen: View {
    @State private var model: SecurityModel
    private let onOpen: (AppRoute) -> Void

    init(service: any AccountService, settings: any SecuritySettings, onOpen: @escaping (AppRoute) -> Void) {
        model = SecurityModel(service: service, settings: settings)
        self.onOpen = onOpen
    }

    var body: some View {
        AccountPage("account.security.title", back: "account.back.profile") {
            AccountIntro(illustration: .shield, title: "account.security.intro")
            switch model.phase {
            case .loading, .empty:
                SecuritySettingsList(model: model, preferences: Self.placeholder)
                    .redacted(reason: .placeholder).disabled(true)
            case .loaded(let preferences):
                SecuritySettingsList(model: model, preferences: preferences)
            case .failed(let problem):
                AccountFailure(problem: problem) { Task { await model.load() } }
            }
            KiraNotice(.privacy, message: "account.security.notice")
        }
        .onHelp { onOpen(.care) }
        .task { await model.load() }
        .kiraSheet(
            isPresented: Binding(get: { model.pinPrompt != nil }, set: { if !$0 { model.cancelPin() } }),
            title: model.pinPrompt?.title ?? "account.pin.create.title"
        ) {
            PinSheet(model: model)
        }
        .kiraSheet(isPresented: $model.isChoosingAutoLock, title: "account.security.autoLock") {
            AutoLockSheet(model: model)
        }
        .kiraDialog(isPresented: Binding(get: { model.problem != nil }, set: { if !$0 { model.problem = nil } })) {
            KiraDialog(
                "account.failure.title", message: model.problem?.message ?? "problem.unknown", art: .failure,
                primary: KiraButton("account.close") {})
        }
    }

    private static let placeholder = SecurityPreferences(
        isPinLockEnabled: true, autoLock: .immediately, obscuresAppSwitcher: true)
}

/** Kunci Aplikasi and Tampilan. */
private struct SecuritySettingsList: View {
    let model: SecurityModel
    let preferences: SecurityPreferences

    var body: some View {
        KiraListGroup("account.security.lock") {
            KiraListRow(
                Text("account.security.pin"), leading: .icon(.lock),
                trailing: .toggle(Binding(get: { preferences.isPinLockEnabled }, set: { model.setPinLock($0) }))
            )
            .subtitle(Text("account.security.pin.subtitle"))
            if preferences.isPinLockEnabled {
                KiraListRow(Text("account.security.changePin"), leading: .icon(.key), action: model.changePin)
                    .subtitle(Text("account.security.changePin.subtitle"))
                KiraListRow(Text("account.security.autoLock"), leading: .icon(.clock)) {
                    model.isChoosingAutoLock = true
                }
                .value(Text(preferences.autoLock.title))
            }
        }
        KiraListGroup("account.security.display") {
            KiraListRow(
                Text("account.security.hideBalances"), leading: .icon(.eyeOff),
                trailing: .toggle(
                    Binding(get: { model.hidesBalances }, set: { isOn in Task { await model.setHidesBalances(isOn) } }))
            )
            .subtitle(Text("account.security.hideBalances.subtitle"))
            KiraListRow(
                Text("account.security.obscure"), leading: .icon(.image),
                trailing: .toggle(
                    Binding(
                        get: { preferences.obscuresAppSwitcher },
                        set: { isOn in Task { await model.setObscuresAppSwitcher(isOn) } }))
            )
            .subtitle(Text("account.security.obscure.subtitle"))
        }
    }
}

extension AutoLockDelay {
    /** Segera, 1 menit, 5 menit. */
    var title: LocalizedStringResource {
        switch self {
        case .immediately: "account.autoLock.immediately"
        case .oneMinute: "account.autoLock.oneMinute"
        case .fiveMinutes: "account.autoLock.fiveMinutes"
        }
    }
}
