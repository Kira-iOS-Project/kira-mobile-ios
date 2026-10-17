/**
 Profil (AKN-01, canvas Profil): the account's centre. Identity and plan, this month's AI quota,
 the doors to money, security, privacy and the subscription, Kira Peduli, Tentang Kira and Keluar,
 which asks in a sheet before it signs out and clears the device.
 */
import Domain
import Features
import SwiftUI

/** The Profil screen, opened from the avatar on Beranda. */
struct ProfileScreen: View {
    @State private var model: ProfileModel
    private let onOpen: (AppRoute) -> Void

    init(
        service: any AccountService, settings: any SecuritySettings, onOpen: @escaping (AppRoute) -> Void,
        onSignedOut: @escaping @MainActor () -> Void
    ) {
        model = ProfileModel(service: service, settings: settings, onSignedOut: onSignedOut)
        self.onOpen = onOpen
    }

    var body: some View {
        AccountPage("account.profile.title", back: "account.profile.back") {
            switch model.phase {
            case .loading, .empty:
                content(AccountSamples.profile).redacted(reason: .placeholder).disabled(true)
            case .loaded(let profile):
                content(profile)
            case .failed(let problem):
                AccountFailure(problem: problem) { Task { await model.load() } }
            }
        }
        .onHelp { onOpen(.unavailable(.care)) }
        .leaf(size: 150)
        .task { await model.load() }
        .kiraSheet(isPresented: $model.isConfirmingSignOut, title: "account.signOut.title") {
            SignOutSheet(model: model)
        }
    }

    private func content(_ profile: AccountProfile) -> some View {
        ProfileContent(
            profile: profile, isPinLockEnabled: model.isPinLockEnabled, onOpen: onOpen,
            onSignOut: model.askToSignOut)
    }
}

/** The loaded Profil, top to bottom as on the board. */
private struct ProfileContent: View {
    let profile: AccountProfile
    let isPinLockEnabled: Bool
    let onOpen: (AppRoute) -> Void
    let onSignOut: () -> Void

    var body: some View {
        ProfileIdentity(profile: profile)
        ProfileQuotaCard(usage: profile.usage) { onOpen(.plans(yearly: false)) }
        KiraListGroup("account.profile.money") {
            KiraListRow(Text("account.profile.wallets"), leading: .icon(.wallet)) { onOpen(.wallets) }
                .subtitle(Text("account.profile.wallets.subtitle \(profile.debtAccountCount)"))
            KiraListRow(Text("account.profile.bills"), leading: .icon(.calendar)) { onOpen(.bills) }
            KiraListRow(Text("account.profile.budget"), leading: .icon(.chart)) { onOpen(.unavailable(.budget)) }
                .subtitle(periodText)
        }
        KiraListGroup("account.profile.account") {
            KiraListRow(Text("account.profile.security"), leading: .icon(.lock)) { onOpen(.security) }
                .subtitle(Text(isPinLockEnabled ? "account.profile.security.on" : "account.profile.security.off"))
            KiraListRow(Text("account.profile.privacy"), leading: .icon(.shield)) { onOpen(.privacy) }
                .subtitle(Text("account.profile.privacy.subtitle"))
            KiraListRow(Text("account.profile.subscription"), leading: .icon(.star)) { onOpen(.subscription) }
                .subtitle(Text(profile.plan.id.title))
        }
        KiraHelpButton(.row) { onOpen(.unavailable(.care)) }
        KiraListGroup("account.profile.more") {
            KiraListRow(Text("account.profile.about"), leading: .icon(.info)) { onOpen(.about) }
                .subtitle(Text("account.version \(Bundle.main.shortVersion)"))
            KiraListRow(Text("account.profile.signOut"), leading: .icon(.logout), trailing: .none, action: onSignOut)
        }
    }

    /** "Periode 25 September – 24 Oktober 2026". */
    private var periodText: Text {
        let start = profile.period.start.date
        let end = profile.period.end.date
        return Text("account.profile.budget.subtitle \(start, format: .accountDayMonth) \(end, format: .accountDay)")
    }
}

/** The avatar, the name, the email and the plan's tag. */
private struct ProfileIdentity: View {
    let profile: AccountProfile
    @Environment(\.dynamicTypeSize) private var typeSize

    /** The avatar beside the words, above them at the accessibility text sizes. */
    private var layout: AnyLayout {
        typeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: KiraSpacing.space3))
            : AnyLayout(HStackLayout(spacing: KiraSpacing.space4))
    }

    var body: some View {
        layout {
            KiraAvatar(profile.initial, size: 64, tone: .turmeric)
            VStack(alignment: .leading, spacing: 2) {
                Text(profile.displayName).kiraFont(.title).accessibilityAddTraits(.isHeader)
                Text(profile.email).font(.subheadline).kiraLineHeight(20, size: 15).foregroundStyle(.inkMuted)
                    /** "Email dinda@email.com": an address alone reads as an identifier, not a label. */
                    .accessibilityLabel(Text("account.profile.email.label \(profile.email)"))
                KiraTag(profile.plan.id.title, tone: .pandan, icon: .sparkle).padding(.top, 6)
            }
        }
        .padding(EdgeInsets(top: 8, leading: 4, bottom: 4, trailing: 4))
    }
}

extension Bundle {
    /** The app's version from the build ("1.0.0"), shown on Profil and Tentang Kira. */
    var shortVersion: String {
        (infoDictionary?["CFBundleShortVersionString"] as? String) ?? ""
    }
}
