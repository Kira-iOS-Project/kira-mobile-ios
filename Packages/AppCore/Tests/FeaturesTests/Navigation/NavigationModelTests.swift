import Domain
import Testing

@testable import Features

@MainActor
@Suite("NavigationModel")
struct NavigationModelTests {
    @Test("starts on Beranda with the dock")
    func start() {
        let navigation = NavigationModel()
        #expect(navigation.section == .home)
        #expect(navigation.showsDock)
    }

    @Test("pushes a route on the open section's stack")
    func push() {
        let navigation = NavigationModel()
        navigation.open(.score)
        #expect(navigation.homePath == [.score])
        #expect(navigation.showsDock)
        navigation.open(.indicator(.emergencyFund))
        #expect(!navigation.showsDock)
        navigation.open(.record)
        navigation.open(.conversation(messageId: "m1"))
        #expect(navigation.section == .record)
        #expect(navigation.recordPath == [.conversation(messageId: "m1")])
        #expect(navigation.homePath == [.score, .indicator(.emergencyFund)])
    }

    @Test("Beranda and Catat return to their root when tapped while open")
    func reselect() {
        let navigation = NavigationModel()
        navigation.open(.profile)
        navigation.select(.record)
        navigation.open(.history)
        navigation.select(.record)
        #expect(navigation.recordPath.isEmpty)
        navigation.open(.home)
        #expect(navigation.homePath == [.profile])
        navigation.open(.home)
        #expect(navigation.homePath.isEmpty)
    }

    @Test("Rencana, Komunitas and unavailable areas open nothing")
    func unavailable() {
        let navigation = NavigationModel()
        navigation.select(.plan)
        navigation.select(.community)
        for area in UnavailableArea.allCases { navigation.open(.unavailable(area)) }
        #expect(navigation.section == .home)
        #expect(navigation.homePath.isEmpty)
    }

    @Test("reset returns to an empty Beranda")
    func reset() {
        let navigation = NavigationModel()
        navigation.open(.profile)
        navigation.select(.record)
        navigation.open(.history)
        navigation.reset()
        #expect(navigation.section == .home)
        #expect(navigation.homePath.isEmpty)
        #expect(navigation.recordPath.isEmpty)
    }

    @Test("the dock stays on the screens whose board draws it")
    func dockRoutes() {
        let withDock: [AppRoute] = [.score, .voiceInput, .conversation(messageId: "m1")]
        let without: [AppRoute] = [.history, .recordManual, .profile, .checkout(.plus, yearly: true)]
        #expect(withDock.map(\.showsDock) == [true, true, true])
        #expect(without.map(\.showsDock) == [false, false, false, false])
    }
}
