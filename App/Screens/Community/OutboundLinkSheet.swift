/**
 Membuka Tautan Keluar (KOM-04): every time a group's link opens, the group, the day its link was
 checked and the warning that real admins never ask for an OTP, a PIN or money. "Buka WhatsApp"
 opens the invite (the browser when the app is missing); Batal goes back to the group.
 */
import Domain
import SwiftUI

struct OutboundLinkSheet: View {
    let group: CommunityGroup?
    let invite: GroupInvite?
    let onClose: () -> Void
    @Environment(\.openURL) private var openURL

    var body: some View {
        if let group, let invite {
            VStack(spacing: KiraSpacing.space2) {
                KiraIllustration(.community, size: 80)
                Text("community.outbound.title \(Text(invite.platform.title))")
                    .font(KiraFont.display(22, .heavy, relativeTo: .title2))
                    .kiraLineHeight(28, size: 22, natural: 1.26, relativeTo: .title2)
                    .tracking(-0.33)
                    .foregroundStyle(.ink)
                    .accessibilityAddTraits(.isHeader)
                Text("community.outbound.meta \(group.summary.name) \(invite.linkCheckedOn.date.formatted(.kiraDate))")
                    .kiraFont(.callout).foregroundStyle(.inkMuted)
            }
            .multilineTextAlignment(.center)
            .padding(.top, 10)
            KiraNotice(.warning, title: "community.outbound.warning.title", message: "community.outbound.warning.body")
            Spacer(minLength: 0)
            KiraButtonPair(
                secondary: KiraButton("community.outbound.cancel", variant: .secondary, size: .small, action: onClose),
                primary: KiraButton(invite.platform.openTitle, size: .small) {
                    openURL(invite.url)
                    onClose()
                }
                .iconEnd(.external))
                .padding(.bottom, KiraSpacing.space2)
        }
    }
}
