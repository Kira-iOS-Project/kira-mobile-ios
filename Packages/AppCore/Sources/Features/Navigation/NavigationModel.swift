import Observation

/** The main shell's sections: the dock's three destinations and Catat. */
package enum MainSection: CaseIterable, Sendable {
    /** Beranda. */
    case home
    /** Catat, the dock's main action. */
    case record
    /** Rencana (REN): not built yet; the tab stays visible and opens nothing. */
    case plan
    /** Komunitas (KOM): not built yet; the tab stays visible and opens nothing. */
    case community
}

/**
 Where the main shell is: the open section and one navigation stack per built section. Screens
 open destinations through `open(_:)`; Beranda and Catat switch sections, every other route is
 pushed on the open section's stack, and an unavailable area does nothing.
 */
@MainActor @Observable
package final class NavigationModel {
    /** The open section: Beranda or Catat. */
    package private(set) var section: MainSection = .home
    /** Beranda's stack. */
    package var homePath: [AppRoute] = []
    /** Catat's stack. */
    package var recordPath: [AppRoute] = []

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
        case .unavailable: break
        default:
            if section == .record { recordPath.append(route) } else { homePath.append(route) }
        }
    }

    /**
     A dock tap: Beranda or Catat opens its section, or returns to its root when it is open
     already; Rencana and Komunitas are unavailable and do nothing.
     */
    package func select(_ target: MainSection) {
        switch target {
        case .home:
            if section == .home { homePath.removeAll() }
            section = .home
        case .record:
            if section == .record { recordPath.removeAll() }
            section = .record
        case .plan, .community:
            break
        }
    }

    /** Back to Beranda with empty stacks (sign-out). */
    package func reset() {
        section = .home
        homePath.removeAll()
        recordPath.removeAll()
    }

    private var currentPath: [AppRoute] {
        section == .record ? recordPath : homePath
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
