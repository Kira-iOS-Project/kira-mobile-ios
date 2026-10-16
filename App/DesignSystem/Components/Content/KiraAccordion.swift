/**
 Accordion (design system): detail that waits until it is wanted, closed by default; the whole
 title row is the button. For what not everyone needs (the Kira Score formula, method sources,
 legal notes, FAQ), never for what the screen's decision needs. Title Case, a question is fine
 ("Gimana Ngitungnya?"); `subtitle` says in one line what is inside. Built on DisclosureGroup, so
 VoiceOver reads it as expandable; the chevron stops turning under Reduce Motion.
 */
import SwiftUI

/** A card that opens to show detail. */
struct KiraAccordion<Content: View>: View {
    private let title: LocalizedStringResource
    private let subtitle: LocalizedStringResource?
    private let icon: KiraIconName?
    private let binding: Binding<Bool>?
    private let content: Content
    private var isSoft = false
    private var opensAtFirst = false
    /** Whether the person has opened or closed it; until then `opensAtFirst` decides. */
    @State private var wasToggled = false
    @State private var isOpen = false
    @Environment(\.dynamicTypeSize) private var typeSize

    /** Closed by default (`.openByDefault()` opens it); pass `isExpanded` to open or close it from outside. */
    init(
        _ title: LocalizedStringResource, subtitle: LocalizedStringResource? = nil, icon: KiraIconName? = nil,
        isExpanded: Binding<Bool>? = nil, @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.binding = isExpanded
        self.content = content()
    }

    var body: some View {
        DisclosureGroup(
            isExpanded: binding
                ?? Binding(
                    get: { wasToggled ? isOpen : opensAtFirst },
                    set: {
                        wasToggled = true
                        isOpen = $0
                    })
        ) {
            content
        } label: {
            header
        }
        .disclosureGroupStyle(KiraAccordionStyle(isSoft: isSoft))
    }

    /**
     The icon beside the title as in the artifact. At the accessibility sizes the icon and the
     chevron share a row above the title (an empty 38 pt one without an icon), so the title has the
     card's whole width and wraps between words, never inside one ("Ngitungnya?").
     */
    private var header: some View {
        let row =
            typeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: KiraSpacing.space2))
            : AnyLayout(HStackLayout(spacing: KiraSpacing.space3))
        return row {
            if let icon {
                KiraIcon(icon, size: 20)
                    .foregroundStyle(.pandan)
                    .frame(width: 38, height: 38)
                    .kiraCard(
                        isSoft ? .surfaceRaised : .pandanSoft, border: .pandanLine, cornerRadius: KiraRadius.small)
            } else if typeSize.isAccessibilitySize {
                Color.clear.frame(width: 38, height: 38)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.headline).kiraLineHeight(22, size: 17).foregroundStyle(.ink)
                if let subtitle {
                    Text(subtitle).font(.footnote).kiraLineHeight(18, size: 13).foregroundStyle(.inkMuted)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    /** The same accordion on pandan-soft, the green version. */
    func soft() -> Self {
        var accordion = self
        accordion.isSoft = true
        return accordion
    }

    /** The same accordion, open until the person closes it (the design system's `defaultOpen`). */
    func openByDefault() -> Self {
        var accordion = self
        accordion.opensAtFirst = true
        return accordion
    }
}

private struct KiraAccordionStyle: DisclosureGroupStyle {
    let isSoft: Bool

    func makeBody(configuration: Configuration) -> some View {
        AccordionBody(configuration: configuration, isSoft: isSoft)
    }
}

private struct AccordionBody: View {
    let configuration: DisclosureGroupStyleConfiguration
    let isSoft: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        VStack(spacing: 0) {
            Button {
                withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.2)) { configuration.isExpanded.toggle() }
            } label: {
                Group {
                    if typeSize.isAccessibilitySize {
                        /** On the icon's row, centred on its 38 pt. */
                        configuration.label.overlay(alignment: .topTrailing) { chevron.padding(.top, 5) }
                    } else {
                        HStack(spacing: KiraSpacing.space3) {
                            configuration.label
                            chevron
                        }
                    }
                }
                .padding(.vertical, KiraSpacing.space3)
                .padding(.horizontal, KiraSpacing.space4)
                .frame(minHeight: 64)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityValue(Text(configuration.isExpanded ? "ds.accordion.open" : "ds.accordion.closed"))
            if configuration.isExpanded {
                VStack(alignment: .leading, spacing: KiraSpacing.space3) { configuration.content }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, KiraSpacing.space4)
                    .overlay(alignment: .top) { Rectangle().fill(.line).frame(height: 1) }
                    .padding(.horizontal, KiraSpacing.space4)
            }
        }
        .kiraCard(
            isSoft ? .pandanSoft : .surfaceRaised, border: isSoft ? .pandanLine : .hairline,
            cornerRadius: KiraRadius.medium)
    }

    private var chevron: some View {
        KiraIcon(.chevronDown, size: 18, weight: .semibold)
            .foregroundStyle(.inkMuted)
            .rotationEffect(.degrees(configuration.isExpanded ? 180 : 0))
            .frame(width: 28, height: 28)
            .background(.surfaceMuted, in: Circle())
    }
}

#if DEBUG
    #Preview { GalleryLabels().galleryPage() }
#endif
