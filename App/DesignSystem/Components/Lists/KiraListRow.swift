/**
 ListRow (design system): a tile on the left, the title and its details stacked, an action on the
 right. Numbers always sit under the title, left-aligned (`.amount`, `.value`), so long names and
 big amounts stay whole; the right side is for actions only: chevron, toggle, check, or an outside
 link. `extra` holds a Tag or a ProgressRibbon under the text. `.danger()` is for rows that delete
 (Hapus Akun dan Data): vulnerable, never the emergency red. The title is a Text, so it holds copy
 (`Text("settings.pin")`) or data (`Text(transaction.name)`) alike.
 */
import SwiftUI

/** One row of a KiraListGroup. */
struct KiraListRow<Extra: View>: View {
    typealias Leading = KiraListRowLeading
    typealias Trailing = KiraListRowTrailing

    private let title: Text
    private let leading: Leading
    private let trailing: Trailing
    private let action: (() -> Void)?
    private let extra: Extra
    private var subtitle: Text?
    private var amount: KiraAmount?
    private var value: Text?
    private var isDanger = false
    @Environment(\.dynamicTypeSize) private var typeSize

    init(
        _ title: Text, leading: Leading = .none, trailing: Trailing = .automatic, action: (() -> Void)? = nil,
        @ViewBuilder extra: () -> Extra
    ) {
        self.title = title
        self.leading = leading
        self.trailing = trailing
        self.action = action
        self.extra = extra()
    }

    var body: some View {
        Group {
            if let action {
                Button(action: action) { row }
                    .buttonStyle(.plain)
                    .accessibilityAddTraits(isChecked ? .isSelected : [])
            } else if case .toggle = trailing {
                row
            } else {
                /** A row without an action reads as one element, its parts in order. */
                row.accessibilityElement(children: .combine)
            }
        }
        .kiraRowSeparator()
    }

    private var isChecked: Bool {
        if case .check(true) = trailing { return true }
        return false
    }

    /** A switch goes under the title at the accessibility sizes, so the title keeps its words whole. */
    private var stacksTrailing: Bool {
        if case .toggle = trailing { return typeSize.isAccessibilitySize }
        return false
    }

    private var row: some View {
        let layout =
            stacksTrailing
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: KiraSpacing.space2))
            : AnyLayout(HStackLayout(spacing: KiraSpacing.space3))
        return layout {
            HStack(spacing: KiraSpacing.space3) {
                RowLeadingTile(leading: leading, isDanger: isDanger)
                main
            }
            trailingView
        }
        .padding(.vertical, KiraSpacing.space3)
        .frame(minHeight: 60)
        .contentShape(Rectangle())
    }

    private var main: some View {
        VStack(alignment: .leading, spacing: 2) {
            title.font(.callout.weight(.semibold)).kiraLineHeight(21, size: 16).foregroundStyle(
                isDanger ? Color.vulnerable : Color.ink)
            if let subtitle {
                subtitle.font(.footnote).kiraLineHeight(18, size: 13).foregroundStyle(.inkMuted)
            }
            if let amount { amount.padding(.top, 2) }
            if let value {
                value.font(.subheadline.weight(.semibold)).kiraLineHeight(20, size: 15)
                    .foregroundStyle(.ink).padding(.top, 2)
            }
            VStack(alignment: .leading, spacing: 6) { extra }.padding(.top, Extra.self == EmptyView.self ? 0 : 6)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder private var trailingView: some View {
        switch trailing {
        case .automatic:
            if action != nil { chevron(.chevronRight) }
        case .chevron:
            chevron(.chevronRight)
        case .external:
            KiraIcon(.external, size: 18).foregroundStyle(.inkMuted)
        case .toggle(let isOn):
            KiraToggle(label: title, isOn: isOn)
        case .check(let isOn):
            Circle()
                .fill(isOn ? Color.pandan : .clear)
                .overlay { Circle().strokeBorder(isOn ? Color.pandan : .lineStrong, lineWidth: 1.5) }
                .overlay { if isOn { KiraIcon(.check, size: 16, weight: .bold).foregroundStyle(.onPandan) } }
                .frame(width: 24, height: 24)
        case .none:
            EmptyView()
        }
    }

    private func chevron(_ icon: KiraIconName) -> some View {
        KiraIcon(icon, size: 20).foregroundStyle(.inkMuted)
    }

    /** The same row with a short line under the title. */
    func subtitle(_ text: Text) -> Self { copy { $0.subtitle = text } }

    /** The same row with an amount under the title, such as `KiraAmount(value, size: .small).signed()`. */
    func amount(_ amount: KiraAmount) -> Self { copy { $0.amount = amount } }

    /** The same row with a short value under the title ("3 hari sebelumnya"). */
    func value(_ text: Text) -> Self { copy { $0.value = text } }

    /** The same row as a destructive one, in vulnerable. */
    func danger() -> Self { copy { $0.isDanger = true } }

    private func copy(_ change: (inout Self) -> Void) -> Self {
        var row = self
        change(&row)
        return row
    }
}

extension KiraListRow where Extra == EmptyView {
    init(
        _ title: Text, leading: Leading = .none, trailing: Trailing = .automatic, action: (() -> Void)? = nil
    ) {
        self.init(title, leading: leading, trailing: trailing, action: action) { EmptyView() }
    }
}

#if DEBUG
    #Preview { GalleryLists().galleryPage() }
#endif
