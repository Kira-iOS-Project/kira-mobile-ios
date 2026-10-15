// StepProgress (design system): the steps of a staged flow (the health check quiz, the risk
// profile quiz, a statement import), so the person always knows how many are left. "Nanti Saja"
// stays available and answers are kept.
import SwiftUI

/// A row of step segments with "Langkah 2 dari 6" under it.
struct KiraStepProgress: View {
    private let current: Int
    private let total: Int

    /// `current` counts from 1. The line under the bar always shows: it says how many steps are left.
    init(current: Int, total: Int) {
        self.current = current
        self.total = max(total, 1)
    }

    private var label: LocalizedStringResource { "ds.steps.label \(current) \(total)" }

    var body: some View {
        VStack(alignment: .leading, spacing: KiraSpacing.space2) {
            HStack(spacing: 4) {
                ForEach(1...total, id: \.self) { step in
                    Capsule()
                        .fill(step <= current ? Color.pandan : Color.track)
                        .frame(height: 6)
                }
            }
            Text(label).font(.footnote.weight(.semibold)).foregroundStyle(.inkMuted)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(label))
    }
}

#if DEBUG
    #Preview { GalleryProgress().galleryPage() }
#endif
