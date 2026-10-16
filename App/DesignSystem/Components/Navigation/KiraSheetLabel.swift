/** The VoiceOver name of a `KiraSheet` without a header (Tautan Keluar). */
import SwiftUI

extension View {
    /** Names a header-less sheet for VoiceOver; a sheet with a header is named by its title. */
    @ViewBuilder
    func sheetLabel(_ label: LocalizedStringResource?) -> some View {
        if let label {
            accessibilityLabel(Text(label))
        } else {
            self
        }
    }
}
