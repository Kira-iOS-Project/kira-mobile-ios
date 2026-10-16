/**
 "Samarkan di Pengalih Aplikasi" (AKN-03): while Kira is in the app switcher, its screen is
 blurred and covered by the surface with the mark, so no amount can be read there.
 */
import SwiftUI

struct PrivacyCover: View {
    var body: some View {
        ZStack {
            Rectangle().fill(.surface.opacity(0.92))
            KiraLogo(.mark, size: 64)
        }
        .ignoresSafeArea()
        .accessibilityHidden(true)
    }
}
