// The tile on the left of a KiraListRow: a category tile, a line icon in a pandan-soft square, a
// spot illustration, or a person's initials. Decorative: the row's title names it.
import SwiftUI

/// The tile on the left.
enum KiraListRowLeading {
    case none
    case category(KiraCategory)
    case icon(KiraIconName)
    case illustration(KiraIllustrationName)
    case initials(String, KiraAvatar.Tone)
}

/// The action on the right.
enum KiraListRowTrailing {
    /// A chevron when the row has an action, else nothing (default).
    case automatic
    case chevron
    /// Opens an official site outside the app.
    case external
    /// A switch named after the row's title.
    case toggle(Binding<Bool>)
    /// A single or multiple choice mark.
    case check(Bool)
    case none
}

/// Draws a row's leading tile.
struct RowLeadingTile: View {
    let leading: KiraListRowLeading
    let isDanger: Bool

    var body: some View {
        switch leading {
        case .none:
            EmptyView()
        case .category(let category):
            KiraCategoryIcon(category, size: KiraSize.tile)
        case .icon(let icon):
            KiraIcon(icon, size: 20)
                .foregroundStyle(isDanger ? Color.rentan : Color.pandan)
                .frame(width: 38, height: 38)
                .kiraCard(
                    isDanger ? .rentanSoft : .pandanSoft, border: isDanger ? .rentanLine : .pandanLine,
                    cornerRadius: KiraRadius.small)
        case .illustration(let name):
            KiraIllustration(name, size: 44)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .hairline(cornerRadius: 14)
        case .initials(let initials, let tone):
            KiraAvatar(initials, size: KiraSize.tile, tone: tone)
        }
    }
}
