/**
 Toggle (design system): an iOS-shaped switch, flat: a pandan track when on, `track` when off, a
 white knob with a hairline and no shadow (the system switch's knob casts one, so Kira draws its
 own). For settings that apply at once: the PIN lock, hiding balances, consent per data purpose.
 VoiceOver reads it as a switch (the toggle trait) named by `label`, with its state; inside a
 ListRow the label is the row's title.
 */
import SwiftUI

/** A flat on/off switch with an accessible name. */
struct KiraToggle: View {
    private let label: Text
    @Binding private var isOn: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    init(_ label: LocalizedStringResource, isOn: Binding<Bool>) {
        self.init(label: Text(label), isOn: isOn)
    }

    /** A switch named by a row's title. */
    init(label: Text, isOn: Binding<Bool>) {
        self.label = label
        _isOn = isOn
    }

    var body: some View {
        Button {
            withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.2)) { isOn.toggle() }
        } label: {
            ZStack(alignment: isOn ? .trailing : .leading) {
                Capsule().fill(isOn ? Color.pandan : Color.track)
                Capsule().strokeBorder(isOn ? Color.pandan : Color.hairline, lineWidth: 1)
                Circle()
                    .fill(.iluPutih)
                    .overlay { Circle().strokeBorder(.hairline, lineWidth: 1) }
                    .frame(width: 25, height: 25)
                    .padding(3)
            }
            .frame(width: 51, height: 31)
            .frame(minHeight: KiraSize.tap)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
        .accessibilityValue(Text(isOn ? "ds.toggle.on" : "ds.toggle.off"))
        .accessibilityAddTraits(.isToggle)
    }
}

#if DEBUG
    #Preview { GalleryForms().galleryPage() }
#endif
