/**
 The tabs: Beranda and Catat, each its own navigation stack driven by `AppRoute`, under Kira's
 dock (KiraTabBar). Rencana and Komunitas stay on the dock but open nothing yet. The dock shows at
 each root and on the screens whose board draws it (`AppRoute.showsDock`).
 */
import Features
import SwiftUI

struct MainShell: View {
    @Bindable var navigation: NavigationModel
    @Environment(\.appServices) private var services
    /** The window's bottom inset (the home indicator), which the dock's 24 pt are measured past. */
    @State private var bottomInset: CGFloat = 0

    var body: some View {
        TabView(selection: sectionBinding) {
            NavigationStack(path: $navigation.homePath) {
                HomeSlot(onOpen: navigation.open)
                    .navigationDestination(for: AppRoute.self, destination: destination)
            }
            .tag(MainSection.home)
            .toolbar(.hidden, for: .tabBar)
            NavigationStack(path: $navigation.recordPath) {
                RecordSlot(onOpen: navigation.open)
                    .navigationDestination(for: AppRoute.self, destination: destination)
            }
            .tag(MainSection.record)
            .toolbar(.hidden, for: .tabBar)
            NavigationStack(path: $navigation.communityPath) {
                CommunitySlot(onOpen: navigation.open)
                    .navigationDestination(for: AppRoute.self, destination: destination)
            }
            .tag(MainSection.community)
            .toolbar(.hidden, for: .tabBar)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if navigation.showsDock {
                KiraTabBar(selection: tabBinding, isRecordActive: navigation.section == .record) {
                    navigation.select(.record)
                }
                .padding(.horizontal, KiraSpacing.screen)
                /** The boards' `bottom: 24px` from the screen's edge, into the home indicator's 34 pt. */
                .padding(.bottom, 24 - bottomInset)
            }
        }
        /** Read outside the inset above, which would add the dock's own height (and loop). */
        .onGeometryChange(for: CGFloat.self) {
            $0.safeAreaInsets.bottom
        } action: {
            bottomInset = $0
        }
        .fullScreenCover(isPresented: $navigation.showsHealthCheck) {
            OnboardingFlow(service: services.onboarding, pinSetup: services.pinSetup, start: .healthCheck) { _ in
                navigation.showsHealthCheck = false
            }
        }
    }

    private func destination(_ route: AppRoute) -> some View {
        RouteDestination(route: route, onOpen: navigation.open)
    }

    /** The TabView follows the model; a swipe or system change goes through `select`. */
    private var sectionBinding: Binding<MainSection> {
        Binding(get: { navigation.section }, set: { navigation.select($0) })
    }

    /** The dock's selection: Komunitas in its section, else Beranda (also while the ring marks Catat). */
    private var tabBinding: Binding<KiraTab> {
        Binding(
            get: { navigation.section == .community ? .community : .home },
            set: { tab in
                switch tab {
                case .home: navigation.select(.home)
                case .plan: navigation.select(.plan)
                case .community: navigation.select(.community)
                }
            })
    }
}
