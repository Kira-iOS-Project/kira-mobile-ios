/**
 AKN's plan screens for `ScreenLaunch`: Paket (monthly and yearly), Kira Plus, its checkout, Kelola
 Langganan with its invoices and Traktir Kira, and Beasiswa Kira before, during and after review.
 */
#if DEBUG
    import Domain
    import Features
    import SwiftUI

    struct PlansLaunch: View {
        let screen: LaunchScreen
        private let service = PreviewPlansService()

        var body: some View {
            NavigationStack {
                switch screen {
                case .plansYearly: PlansScreen(service: service, onOpen: { _ in }, period: .yearly)
                case .planDetail: PlanDetailView(terms: plus, period: .monthly, service: service) { _ in }
                case .checkout: CheckoutView(terms: plus, period: .monthly, service: service) {}
                case .subscription: SubscriptionScreen(service: service) { _ in }
                case .invoices: InvoicesView(service: service)
                case .treat: TreatView(service: service)
                case .scholarship: ScholarshipScreen(service: PreviewPlansService(onFreePlan: true)) { _ in }
                case .scholarshipApply:
                    ScholarshipApplyView(
                        service: PreviewPlansService(onFreePlan: true), draft: Self.formDraft, onOpen: { _ in },
                        onSent: {})
                case .scholarshipPending: scholarship(Self.pending)
                case .scholarshipAccepted: scholarship(PreviewPlansData.acceptedApplication)
                default: PlansScreen(service: service) { _ in }
                }
            }
        }

        private var plus: PlanTerms { PreviewPlansData.terms[2] }

        private func scholarship(_ application: ScholarshipApplication) -> some View {
            ScholarshipScreen(service: PreviewPlansService(onFreePlan: true, application: application)) { _ in }
        }

        /** BeasiswaKiraForm: two situations picked and the story typed, so Kirim Pengajuan is on. */
        private static let formDraft = ScholarshipDraft(
            situations: [.instalmentsPilingUp, .chasedByLender],
            story: "Aku mau mencatat semua cicilan dari foto struk dan mutasi rekening supaya tahu mana yang harus "
                + "dinego dulu.")

        /** BeasiswaKiraStatus: sent 16 October 2026, a decision by 21 October. */
        private static let pending = ScholarshipApplication(
            id: "app-pending", status: .inReview, situations: [.instalmentsPilingUp], story: nil,
            submittedAt: PreviewPlansData.sentAt, decideBy: CalendarDay(year: 2026, month: 10, day: 21))
    }
#endif
