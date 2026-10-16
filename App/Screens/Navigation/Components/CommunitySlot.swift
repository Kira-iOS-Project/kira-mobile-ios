/** KOM-01: Komunitas, the root of the dock's Komunitas section. */
import Features
import SwiftUI

struct CommunitySlot: View {
    let onOpen: (AppRoute) -> Void
    @Environment(\.appServices) private var services

    var body: some View {
        CommunityScreen(service: services.community, onOpen: onOpen)
    }
}
