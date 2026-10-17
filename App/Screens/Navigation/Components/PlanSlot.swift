/** REN-01: Rencana, the root of the dock's Rencana section. */
import Features
import SwiftUI

struct PlanSlot: View {
    let onOpen: (AppRoute) -> Void
    @Environment(\.appServices) private var services

    var body: some View {
        PlanScreen(service: services.goals, onOpen: onOpen)
    }
}
