/**
 PED's debt screens for `ScreenLaunch`: Mode Darurat Utang and its four guides, on the preview
 services (the shipped contacts).
 */
#if DEBUG
    import Domain
    import Features
    import SwiftUI

    struct DebtEmergencyLaunch: View {
        let screen: LaunchScreen

        var body: some View {
            NavigationStack {
                if let guide {
                    DebtGuideScreen(guide: guide, care: PreviewCareService()) { _ in }
                } else {
                    DebtEmergencyScreen(care: PreviewCareService(), service: PreviewDebtEmergencyService()) { _ in }
                }
            }
        }

        private var guide: DebtGuide? {
            switch screen {
            case .harshCollection: .harshCollection
            case .illegalLender: .illegalLender
            case .unresolvedComplaint: .unresolvedComplaint
            case .payoffOffer: .payoffOffer
            default: nil
            }
        }
    }
#endif
