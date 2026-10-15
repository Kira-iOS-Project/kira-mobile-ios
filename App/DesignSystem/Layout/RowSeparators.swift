// Rows in one card are split by a 1 pt `line` (bundle.css `.k-row + .k-row`). iOS 17 has no public
// way to walk a container's children, so each row draws a line along its top while a container
// asks for it, and the container clips its first row's line away.
import SwiftUI

private struct RowSeparatorsKey: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    /// Whether rows draw a separator along their top edge; KiraRowStack turns it on.
    var kiraRowSeparators: Bool {
        get { self[RowSeparatorsKey.self] }
        set { self[RowSeparatorsKey.self] = newValue }
    }
}

extension View {
    /// The row's top separator, drawn while a KiraRowStack holds it.
    func kiraRowSeparator() -> some View {
        modifier(RowSeparator())
    }
}

private struct RowSeparator: ViewModifier {
    @Environment(\.kiraRowSeparators) private var isOn

    func body(content: Content) -> some View {
        content.overlay(alignment: .top) {
            if isOn { Rectangle().fill(.line).frame(height: 1) }
        }
    }
}

/// A column of rows with a `line` between each two, and none above the first.
struct KiraRowStack<Rows: View>: View {
    private let rows: Rows

    init(@ViewBuilder rows: () -> Rows) {
        self.rows = rows()
    }

    var body: some View {
        VStack(spacing: 0) { rows }
            .environment(\.kiraRowSeparators, true)
            .padding(.top, -1)
            .clipped()
    }
}
