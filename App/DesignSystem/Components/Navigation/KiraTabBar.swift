/**
 TabBar (design system): Kira's dock, not a row of equal tabs. A glass capsule holds the three
 destinations, and only the active one shows its label, as a white pill with a hairline; the
 others are icons with a VoiceOver name. Catat is not a destination but the app's main action, so
 it stands apart as a pandan chat bubble with a sharp bottom-right corner, like a sent message.
 The capsule is the app's only glass: the `glass` token over a blur, with no shadow. Lay it over a
 TabView whose own bar is hidden, and leave space-10 at the end of scrolling content.
 */
import SwiftUI

/** The dock's destinations. */
enum KiraTab: CaseIterable {
    case home, plan, community

    var title: LocalizedStringResource {
        switch self {
        case .home: "ds.tab.home"
        case .plan: "ds.tab.plan"
        case .community: "ds.tab.community"
        }
    }

    var icon: KiraIconName {
        switch self {
        case .home: .home
        case .plan: .target
        case .community: .users
        }
    }
}

/** The navigation dock: three destinations and the Catat button. */
struct KiraTabBar: View {
    @Binding private var selection: KiraTab
    private let isRecordActive: Bool
    private let onRecord: () -> Void
    /** The Catat label's 10 pt (`.k-dock__catat-label`), scaled with Dynamic Type like Caption 2. */
    @ScaledMetric(relativeTo: .caption2) private var recordLabelSize: CGFloat = 10

    /** `isRecordActive` rings the Catat bubble while the Catat screen is open. */
    init(selection: Binding<KiraTab>, isRecordActive: Bool = false, onRecord: @escaping () -> Void) {
        _selection = selection
        self.isRecordActive = isRecordActive
        self.onRecord = onRecord
    }

    var body: some View {
        HStack(spacing: KiraSpacing.space3) {
            HStack(spacing: 4) {
                ForEach(KiraTab.allCases, id: \.self) { tab in
                    tabButton(tab)
                }
            }
            .padding(6)
            .frame(minHeight: 60)
            .background { Capsule().fill(.glass) }
            .background(.ultraThinMaterial, in: Capsule())
            .capsuleHairline()
            recordButton
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(Text("ds.tab.navigation"))
    }

    private func tabButton(_ tab: KiraTab) -> some View {
        let isOn = !isRecordActive && tab == selection
        return Button {
            selection = tab
        } label: {
            HStack(spacing: 7) {
                KiraIcon(tab.icon, size: 22, weight: isOn ? .semibold : .medium, isFilled: isOn)
                    .foregroundStyle(isOn ? Color.pandan : Color.inkMuted)
                if isOn {
                    Text(tab.title).font(.subheadline.weight(.semibold)).kiraLineHeight(20, size: 15)
                        .tracking(-0.15).foregroundStyle(.ink)
                }
            }
            .padding(.leading, isOn ? 13 : 10)
            .padding(.trailing, isOn ? KiraSpacing.space4 : 10)
            .frame(maxWidth: isOn ? nil : .infinity, minHeight: 46)
            .kiraCard(isOn ? .surfaceRaised : .clear, border: isOn ? .hairline : .clear, cornerRadius: KiraRadius.full)
            .contentShape(Capsule())
            /** The active pill keeps its whole label; the icon-only tabs share the rest. */
            .fixedSize(horizontal: isOn, vertical: false)
        }
        .buttonStyle(.plain)
        .layoutPriority(isOn ? 1 : 0)
        .accessibilityLabel(Text(tab.title))
        .accessibilityAddTraits(isOn ? .isSelected : [])
    }

    private var recordButton: some View {
        let bubble = UnevenRoundedRectangle(
            topLeadingRadius: 24, bottomLeadingRadius: 24, bottomTrailingRadius: 8, topTrailingRadius: 24,
            style: .continuous)
        return Button(action: onRecord) {
            VStack(spacing: 1) {
                KiraIcon(isRecordActive ? .chat : .plus, size: 22, weight: .semibold)
                Text("ds.tab.record").font(.system(size: recordLabelSize, weight: .bold)).tracking(0.2)
                    .kiraLineHeight(12, size: 10)
                    .kiraSmallType()
            }
            .foregroundStyle(.onPandan)
            .frame(minWidth: 60, minHeight: 60)
            .background(.pandan, in: bubble)
            .overlay { bubble.strokeBorder(.hairline, lineWidth: 1) }
            .overlay {
                /** The active ring: a 2 pt outline 3 pt outside, its corners grown by the same 4 pt. */
                UnevenRoundedRectangle(
                    topLeadingRadius: 28, bottomLeadingRadius: 28, bottomTrailingRadius: 12, topTrailingRadius: 28,
                    style: .continuous
                )
                .stroke(isRecordActive ? Color.pandan : .clear, lineWidth: 2)
                .padding(-4)
            }
            .contentShape(bubble)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isRecordActive ? .isSelected : [])
        .kiraSmallType()
    }
}

#if DEBUG
    #Preview { GalleryNavigation().galleryPage() }
#endif
