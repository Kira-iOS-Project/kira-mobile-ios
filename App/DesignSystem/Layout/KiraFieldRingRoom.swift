/**
 Room for a focused field's ring inside a scroll view. `KiraField` draws its 3 pt focus ring outside
 its border, as `.k-field:focus` does with a box shadow; a scroll view whose content touches its own
 sides cuts that ring off left and right (Tambah Utang's Sisa Tenor). The margin goes inside the
 scroll content and the same width comes off the outside, so the layout keeps its width.
 */
import SwiftUI

extension View {
    /** On a scroll view whose content has no side padding of its own: the ring shows whole. */
    func kiraFieldRingRoom() -> some View {
        contentMargins(.horizontal, KiraField.ringWidth, for: .scrollContent)
            .padding(.horizontal, -KiraField.ringWidth)
    }
}
