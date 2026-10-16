/**
 Bars (design system): simple columns for the weekly summary and the Kira Score history. The
 highlighted column (pandan) is the period in focus; the others are ilu-hijau-lembut. No red for a
 big spending day and no judging target line; the full amounts are written in the text around it.
 */
import SwiftUI

/** Columns comparing a few values, one of them highlighted. */
struct KiraBars: View {
    /** One column. */
    struct Column: Identifiable {
        let label: LocalizedStringResource
        let value: Double
        var isHighlighted = false
        var caption: LocalizedStringResource?
        let id = UUID()
    }

    private let label: LocalizedStringResource
    private let columns: [Column]
    private let height: CGFloat

    /** `label` describes the chart for VoiceOver. */
    init(_ label: LocalizedStringResource, columns: [Column], height: CGFloat = 112) {
        self.label = label
        self.columns = columns
        self.height = height
    }

    var body: some View {
        let top = max(columns.map(\.value).max() ?? 1, 1)
        HStack(alignment: .bottom, spacing: KiraSpacing.space2) {
            ForEach(columns) { column in
                VStack(spacing: 6) {
                    if let caption = column.caption {
                        Text(caption).font(.caption.weight(.semibold)).foregroundStyle(.inkMuted).fixedSize()
                    }
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(column.isHighlighted ? Color.pandan : Color.iluHijauLembut)
                        .frame(height: max(6, (height * column.value / top).rounded()))
                        .frame(maxWidth: 30)
                        .frame(height: height, alignment: .bottom)
                        .background(.surfaceMuted, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                    Text(column.label)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(column.isHighlighted ? Color.ink : Color.inkMuted)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(label))
    }
}

#if DEBUG
    #Preview { GalleryProgress().galleryPage() }
#endif
