/** The sample service behind Mode Darurat Utang: turning the mode on always succeeds. */
import Features

struct PreviewDebtEmergencyService: DebtEmergencyService {
    func activate() {}
}
