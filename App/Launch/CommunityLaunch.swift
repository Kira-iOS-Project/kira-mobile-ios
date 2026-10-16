/**
 KOM's screens for `ScreenLaunch`: Komunitas, and Detail Grup of Lunas Bareng Jakarta, under which
 the audit tests open Aturan Komunitas, Tautan Keluar, the link still being checked, Laporkan Grup
 and its two dialogs. No preview link is verified except for Tautan Keluar, which opens the
 platform's own address; a failed report runs on a preview service whose connection drops.
 */
#if DEBUG
    import Domain
    import Features
    import SwiftUI

    struct CommunityLaunch: View {
        let screen: LaunchScreen

        var body: some View {
            NavigationStack {
                switch screen {
                case .community: CommunityScreen(service: PreviewCommunityService()) { _ in }
                case .communityOutbound: group(PreviewCommunityService(linksVerified: true))
                case .groupReportFailed: group(PreviewCommunityService(reportsFail: true))
                default: group(PreviewCommunityService())
                }
            }
        }

        private func group(_ service: PreviewCommunityService) -> some View {
            GroupDetailScreen(groupID: PreviewCommunityService.groups[0].id, service: service) { _ in }
        }
    }
#endif
