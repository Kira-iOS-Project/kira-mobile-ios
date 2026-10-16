/**
 The view of each pushed route. The integrator replaces each area's `RouteSlot` with that area's
 entry view: Score (score, indicator, healthCheck), Record (recordManual … importStatement),
 Account (profile … deleteAccount, about … complaints, scholarship), Plans (plans … treat).
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
