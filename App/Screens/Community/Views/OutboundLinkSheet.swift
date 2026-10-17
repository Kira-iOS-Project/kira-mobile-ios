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
            /** At larger text sizes the words scroll inside the panel; the buttons stay under them. */
            ScrollView {
                VStack(spacing: KiraSpacing.space4) {
                    heading(group: group, invite: invite)
                    KiraNotice(
                        .warning, title: "community.outbound.warning.title", message: "community.outbound.warning.body")
                }
            }
            .scrollBounceBehavior(.basedOnSize)
            WeightedRow(weights: [1, 1.3], spacing: KiraSpacing.space2) {
                KiraButton("community.outbound.cancel", variant: .secondary, size: .small, action: onClose).block()
                KiraButton(invite.platform.openTitle, size: .small) {
                    openURL(invite.url)
                    onClose()
                }
                .iconEnd(.external)
                .block()
            }
            .padding(.bottom, KiraSpacing.space2)
        }
    }

    /** The illustration, "Kamu Akan Membuka WhatsApp" and the group with the day its link was checked. */
    private func heading(group: CommunityGroup, invite: GroupInvite) -> some View {
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
        .frame(maxWidth: .infinity)
        .padding(.top, 10)
    }
}
