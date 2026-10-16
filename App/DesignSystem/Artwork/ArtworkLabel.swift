/**
 Artwork reaches VoiceOver as one image with a name, or not at all. The images inside are
 decorative (`Image(decorative:)`), so only the name given here is read.
 */
import SwiftUI

extension View {
    /** One image named `label` for VoiceOver, or hidden from it when `label` is nil. */
    @ViewBuilder
    func artworkLabel(_ label: LocalizedStringResource?) -> some View {
        if let label {
            accessibilityElement(children: .ignore)
                .accessibilityLabel(Text(label))
                .accessibilityAddTraits(.isImage)
        } else {
            accessibilityHidden(true)
        }
    }
}
