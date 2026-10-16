/**
 The view of each pushed route: Riwayat's routes (history, transaction, conversation,
 importStatement) go to `RecordRoute`, every other area's to `RouteSlot`.
 */
import Features
import SwiftUI

struct RouteDestination: View {
    let route: AppRoute
    let onOpen: (AppRoute) -> Void

    var body: some View {
        if RecordRoute.handles(route) {
            RecordRoute(route: route, onOpen: onOpen)
        } else {
            RouteSlot(route: route, onOpen: onOpen)
        }
    }
}
