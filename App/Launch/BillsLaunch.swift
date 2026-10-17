/**
 Tagihan & Cicilan for `ScreenLaunch`: the board's six bills, none at all, and a load that fails.
 */
#if DEBUG
    import Domain
    import SwiftUI

    struct BillsLaunch: View {
        let screen: LaunchScreen

        var body: some View {
            NavigationStack {
                switch screen {
                case .billsEmpty:
                    billsScreen(PreviewBillService(overview: BillOverview(count: 0, monthlyTotal: 0, sections: [])))
                case .billsFailed: billsScreen(PreviewBillService(overview: nil))
                default: billsScreen(PreviewBillService())
                }
            }
        }

        private func billsScreen(_ service: PreviewBillService) -> some View {
            BillsScreen(service: service, onAdd: {}, onEdit: { _ in }, onOpenDebt: { _ in }, onHelp: {})
        }
    }
#endif
