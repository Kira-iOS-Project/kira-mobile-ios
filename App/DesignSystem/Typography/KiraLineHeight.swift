/**
 Line height as the design system sets it (CSS `line-height`, in points for a font of `size`
 points), kept in proportion as Dynamic Type scales the font.
   - Where the design system's line is taller than the font's own (every SF Pro style), iOS 26
     and later set it on every line; on iOS 17 and 18 the system's leading stays, within 2 pt.
   - Where it is shorter (Plus Jakarta Sans at 1.26 em and Kalam at 1.59 em have tall natural
     lines), the text keeps its own line, which Apple's accessibility audit needs to see the glyphs
     fit, and gives the difference back as negative padding above and below, as CSS lets the
     glyphs overflow a short line box. The text then takes the design system's height in layout.
 Without it a single line of 17 pt text is 20.3 pt high where the design system makes it 22.
 */
import SwiftUI

extension View {
    /**
     Sets the text inside to lines of `points` for its `size`-point font, whose own line is
     `natural` times its size, scaled like `style`.
     */
    func kiraLineHeight(
        _ points: CGFloat, size: CGFloat, natural: CGFloat = 1.19, relativeTo style: Font.TextStyle = .body
    ) -> some View {
        modifier(KiraLineHeight(points: points, size: size, natural: natural, style: style))
    }
}

extension View {
    /**
     Marks text the design system sets below the sizes Apple's accessibility audit accepts (the
     11 pt overline, the medium amount's 11 pt "Rp" and ",00", the 10 pt Catat label, the 11 pt
     bar caption and a small avatar's initials), so the gallery's audit test can list them apart:
     docs/design-system.md.
     */
    @ViewBuilder
    func kiraSmallType(_ isSmall: Bool = true) -> some View {
        if isSmall { accessibilityIdentifier("kira.small-type") } else { self }
    }
}

private struct KiraLineHeight: ViewModifier {
    let factor: CGFloat
    let isTaller: Bool
    @ScaledMetric private var overhang: CGFloat

    init(points: CGFloat, size: CGFloat, natural: CGFloat, style: Font.TextStyle) {
        factor = points / size
        isTaller = points >= natural * size
        _overhang = ScaledMetric(wrappedValue: max(0, (natural * size - points) / 2), relativeTo: style)
    }

    func body(content: Content) -> some View {
        if isTaller {
            if #available(iOS 26, *) {
                content.lineHeight(.multiple(factor: factor))
            } else {
                content
            }
        } else if overhang >= 0.5 {
            content.padding(.vertical, -overhang)
        } else {
            content
        }
    }
}
