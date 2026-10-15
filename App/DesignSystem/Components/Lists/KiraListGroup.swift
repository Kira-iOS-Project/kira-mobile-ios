// ListGroup (design system): one hairline card of KiraListRows split by a `line`, for wallets,
// bills, settings and lists of choices. A small Title Case title above it, one sentence under it
// for an explanation or a privacy promise. At most seven rows per card; split longer lists.
import SwiftUI

/// A titled card of rows.
struct KiraListGroup<Rows: View>: View {
    private let title: LocalizedStringResource?
    private let footer: LocalizedStringResource?
    private let rows: Rows

    init(
        _ title: LocalizedStringResource? = nil, footer: LocalizedStringResource? = nil,
        @ViewBuilder rows: () -> Rows
    ) {
        self.title = title
        self.footer = footer
        self.rows = rows()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: KiraSpacing.space2) {
            if let title {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.inkMuted)
                    .padding(.horizontal, KiraSpacing.space1)
                    .accessibilityAddTraits(.isHeader)
            }
            KiraRowStack { rows }
                .padding(.horizontal, KiraSpacing.space4)
                .kiraCard()
            if let footer {
                Text(footer)
                    .font(.footnote)
                    .foregroundStyle(.inkMuted)
                    .padding(.horizontal, KiraSpacing.space1)
            }
        }
    }
}

#if DEBUG
    #Preview { GalleryLists().galleryPage() }
#endif
