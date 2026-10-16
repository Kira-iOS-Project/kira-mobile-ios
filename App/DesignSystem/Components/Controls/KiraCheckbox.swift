/**
 Checkbox (design canvas, ONB-10c "Gajian di akhir bulan"): one choice that is on or off, as a
 full-width row with its label. Unchecked, the row is surface-muted with a hairline and an empty
 24 pt box with a line-strong border; checked, the row turns pandan-soft with a pandan border and
 the box fills pandan with a check. No shadow. For consent and single options in a form; settings
 that apply at once use KiraToggle. VoiceOver reads the label, "Dicentang" or "Belum dicentang",
 and the toggle trait.
 */
import SwiftUI

/** A labelled checkbox row. */
struct KiraCheckbox: View {
    private let label: LocalizedStringResource
    @Binding private var isOn: Bool

    init(_ label: LocalizedStringResource, isOn: Binding<Bool>) {
        self.label = label
        _isOn = isOn
    }

    var body: some View {
        Button {
            isOn.toggle()
        } label: {
            HStack(spacing: KiraSpacing.space3) {
                box
                Text(label)
                    .font(.subheadline).kiraLineHeight(20, size: 15)
                    .foregroundStyle(.ink)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, KiraSpacing.space4)
            .padding(.vertical, KiraSpacing.space2)
            .frame(minHeight: 52)
            .background(isOn ? Color.pandanSoft : Color.surfaceMuted, in: shape)
            .overlay { shape.strokeBorder(isOn ? Color.pandan : Color.hairline, lineWidth: isOn ? 1.5 : 1) }
            .contentShape(shape)
        }
        .buttonStyle(.plain)
        .accessibilityValue(Text(isOn ? "ds.checkbox.checked" : "ds.checkbox.unchecked"))
        .accessibilityAddTraits(.isToggle)
    }

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: KiraRadius.medium, style: .continuous)
    }

    private var box: some View {
        let square = RoundedRectangle(cornerRadius: 8, style: .continuous)
        return
            square
            .fill(isOn ? Color.pandan : Color.surfaceRaised)
            .overlay { square.strokeBorder(isOn ? Color.pandan : Color.lineStrong, lineWidth: 1.5) }
            .overlay {
                if isOn { KiraIcon(.check, size: 16, weight: .bold).foregroundStyle(.onPandan) }
            }
            .frame(width: 24, height: 24)
            .accessibilityHidden(true)
    }
}

#if DEBUG
    #Preview { GalleryEntry().galleryPage() }
#endif
