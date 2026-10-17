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

    @Test("Rencana is its own section: its routes stack there, a second tap or reset empties it")
    func plan() {
        let navigation = NavigationModel()
        navigation.open(.plan)
        #expect(navigation.section == .plan && navigation.showsDock)
        navigation.open(.goal(id: "g-1"))
        #expect(navigation.planPath == [.goal(id: "g-1")] && navigation.homePath.isEmpty)
        navigation.select(.plan)
        #expect(navigation.planPath.isEmpty && navigation.section == .plan)
        navigation.open(.goal(id: "g-1"))
        navigation.reset()
        #expect(navigation.planPath.isEmpty && navigation.section == .home)
    }

    @Test("Komunitas is its own section: its routes stack there, a second tap or reset empties it")
    func community() {
        let navigation = NavigationModel()
        navigation.open(.community)
        #expect(navigation.section == .community)
        navigation.open(.communityGroup(id: "g-1"))
        #expect(navigation.communityPath == [.communityGroup(id: "g-1")] && navigation.homePath.isEmpty)
        navigation.select(.community)
        #expect(navigation.communityPath.isEmpty && navigation.section == .community)
        navigation.open(.communityGroup(id: "g-1"))
        navigation.reset()
        #expect(navigation.communityPath.isEmpty && navigation.section == .home)
    }

    @Test("Rencanaku made from Rencana Pelunasan takes its place; opened elsewhere it is pushed")
    func myPlanReplacesSimulation() {
        let navigation = NavigationModel()
        navigation.open(.debtPlan)
        navigation.open(.myPlan)
        #expect(navigation.homePath == [.myPlan])
        navigation.open(.payoffSimulation)
        navigation.open(.myPlan)
        #expect(navigation.homePath == [.myPlan, .myPlan])
        navigation.open(.myPlan)
        #expect(navigation.homePath == [.myPlan, .myPlan, .myPlan])
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

    @Test("Cek Ulang covers the shell instead of pushing, and reset closes it")
    func healthCheck() {
        let model = NavigationModel()
        model.open(.healthCheck)
        #expect(model.showsHealthCheck && model.homePath.isEmpty)
        model.reset()
        #expect(!model.showsHealthCheck)
    }
}
