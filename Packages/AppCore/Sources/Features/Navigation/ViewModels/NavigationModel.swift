import Observation

/** The main shell's sections: the dock's three destinations and Catat. */
package enum MainSection: CaseIterable, Sendable {
    /** Beranda. */
    case home
    /** Catat, the dock's main action. */
    case record
    /** Rencana (REN-01), the dock's second destination. */
    case plan
    /** Komunitas (KOM-01), the dock's third destination. */
    case community
}

/**
 Where the main shell is: the open section and one navigation stack per section. Screens open
 destinations through `open(_:)`; Beranda, Catat, Rencana and Komunitas switch sections, every other
 route is pushed on the open section's stack.
 */
@MainActor @Observable
package final class NavigationModel {
    /** The open section: Beranda, Catat, Rencana or Komunitas. */
    package private(set) var section: MainSection = .home
    /** Beranda's stack. */
    package var homePath: [AppRoute] = []
    /** Catat's stack. */
    package var recordPath: [AppRoute] = []
    /** Rencana's stack. */
    package var planPath: [AppRoute] = []
    /** Komunitas's stack. */
    package var communityPath: [AppRoute] = []
    /** Whether the health check, opened again from the score ("Cek Ulang"), covers the shell. */
    package var showsHealthCheck = false

    /** A shell on Beranda with empty stacks. */
    package init() {}

    /** Whether the dock shows: at a section's root, and on the screens whose board draws it. */
    package var showsDock: Bool {
        currentPath.last?.showsDock ?? true
    }

    /** Opens `route` from any screen. */
    package func open(_ route: AppRoute) {
        switch route {
        case .home: select(.home)
        case .record: select(.record)
        case .plan: select(.plan)
        case .community: select(.community)
        case .healthCheck: showsHealthCheck = true
        default:
            switch section {
            case .record: push(route, on: &recordPath)
            case .plan: push(route, on: &planPath)
            case .community: push(route, on: &communityPath)
            case .home: push(route, on: &homePath)
            }
        }
    }

    /**
     Pushes `route`, except that Rencanaku opened from Rencana Pelunasan (Jadikan Rencanaku) takes
     its place, so going back leaves the plan for where the person came from, as the board's
     "Kembali ke Beranda" says.
     */
    private func push(_ route: AppRoute, on path: inout [AppRoute]) {
        if route == .myPlan, let last = path.last, last == .debtPlan || last == .payoffSimulation {
            path[path.count - 1] = route
        } else {
            path.append(route)
        }
    }

    /**
     A dock tap: the section opens, or returns to its root when it is open already.
     */
    package func select(_ target: MainSection) {
        switch target {
        case .home:
            if section == .home { homePath.removeAll() }
            section = .home
        case .record:
            if section == .record { recordPath.removeAll() }
            section = .record
        case .community:
            if section == .community { communityPath.removeAll() }
            section = .community
        case .plan:
            if section == .plan { planPath.removeAll() }
            section = .plan
        }
    }

    /** Back to Beranda with empty stacks (sign-out). */
    package func reset() {
        section = .home
        homePath.removeAll()
        recordPath.removeAll()
        planPath.removeAll()
        communityPath.removeAll()
        showsHealthCheck = false
    }

    private var currentPath: [AppRoute] {
        switch section {
        case .record: recordPath
        case .plan: planPath
        case .community: communityPath
        case .home: homePath
        }
    }
}

extension AppRoute {
    /** Whether the dock stays on this screen: its board draws the TabBar. */
    package var showsDock: Bool {
        switch self {
        case .score, .voiceInput, .conversation: true
        default: false
        }
    }
}
