/**
 Atur Budget for `ScreenLaunch`, on its board's figures: saving shows Budget Tersimpan, or, with the
 failing service, Belum Berhasil Menyimpan (the UI tests tap Simpan Budget).
 */
#if DEBUG
    import Domain
    import Features
    import SwiftUI

    struct BudgetEditLaunch: View {
        let screen: LaunchScreen

        var body: some View {
            NavigationStack {
                BudgetSettingsScreen(
                    model: BudgetSettingsModel(
                        service: PreviewBudgetSettingsService(saves: screen != .budgetEditFailing),
                        today: { CalendarDay(year: 2026, month: 10, day: 17) }),
                    onOpen: { _ in })
            }
        }
    }
#endif
