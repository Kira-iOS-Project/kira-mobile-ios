/**
 Segmented (design system): two to four mutually exclusive options in one capsule with a
 hairline: transaction type, payoff method, a chart's period. The chosen option is pandan on
 pandan-soft with a pandan-line border, and VoiceOver reads it as selected.
 */
import SwiftUI

/** A choice of two to four options in one capsule. */
struct KiraSegmented<ID: Hashable>: View {
    /** One option: its id and its label. */
    struct Option: Identifiable {
        let id: ID
        let title: LocalizedStringResource
    }

    private let label: LocalizedStringResource
    private let options: [Option]
    @Binding private var selection: ID
    @Environment(\.dynamicTypeSize) private var typeSize

    /** `label` names the group for VoiceOver. */
    init(_ label: LocalizedStringResource, options: [Option], selection: Binding<ID>) {
        self.label = label
        self.options = options
        _selection = selection
    }

    /**
     Side by side as the board draws it; one above the other at the accessibility sizes, where a
     one-word option ("Pengeluaran") no longer fits half the width and cannot wrap.
     */
    var body: some View {
        let layout =
            typeSize.isAccessibilitySize ? AnyLayout(VStackLayout(spacing: 4)) : AnyLayout(HStackLayout(spacing: 4))
        return layout {
            ForEach(options) { option in
                segment(option)
            }
        }
        .padding(6)
        .kiraCard(.surfaceMuted, cornerRadius: typeSize.isAccessibilitySize ? KiraRadius.extraLarge : KiraRadius.full)
        .accessibilityElement(children: .contain)
        .accessibilityLabel(Text(label))
    }

    private func segment(_ option: Option) -> some View {
        let isOn = option.id == selection
        return Button {
            selection = option.id
        } label: {
            Text(option.title)
                .font(.subheadline.weight(isOn ? .bold : .semibold)).kiraLineHeight(20, size: 15)
                .foregroundStyle(isOn ? Color.pandan : Color.inkMuted)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 18)
                .frame(maxWidth: .infinity, minHeight: KiraSize.tap)
                .kiraCard(
                    isOn ? .pandanSoft : .clear, border: isOn ? .pandanLine : .clear, cornerRadius: KiraRadius.full
                )
                .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isOn ? .isSelected : [])
    }
}

#if DEBUG
    #Preview { GalleryForms().galleryPage() }
#endif
