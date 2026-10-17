/**
 The design system's spacing, radius and size scales (tokens.json: spacing, radius, size), in
 points. Colours are not here: each colour token is a colour set in Assets.xcassets, and Xcode
 generates its symbol, so `.foregroundStyle(.inkMuted)` and `.background(.surfaceRaised)` read the
 token by its name, light or dark.
 */
import CoreGraphics

/** The 4 pt spacing scale, `space-1` … `space-10`. */
nonisolated enum KiraSpacing {
    /** space-1, 4: an icon to its small label. */
    static let space1: CGFloat = 4
    /** space-2, 8: buttons side by side, inside a chip. */
    static let space2: CGFloat = 8
    /** space-3, 12: elements inside a card. */
    static let space3: CGFloat = 12
    /** space-4, 16: the screen margin, a small card's padding. */
    static let space4: CGFloat = 16
    /** space-5, 20: the padding of main and hero cards. */
    static let space5: CGFloat = 20
    /** space-6, 24: between the sections of a screen. */
    static let space6: CGFloat = 24
    /** space-8, 32: breathing room under a big number. */
    static let space8: CGFloat = 32
    /** space-10, 40: room above the floating dock at the end of a scroll. */
    static let space10: CGFloat = 40
    /**
     The floating dock's room past the safe area, for a screen that shows it: its 60 pt, 24 pt from the
     screen's edge, less the home indicator's 34 pt. A dock screen ends its content on
     `space10 + dockReserve`, so its last block sits 40 pt above the dock.
     */
    static let dockReserve: CGFloat = 60 + 24 - 34
    /** The screen margin: space-4. */
    static let screen = space4
}

/** Corner radii. Corners are continuous; buttons, badges and bars are capsules instead. */
nonisolated enum KiraRadius {
    /** radius-xs, 6: a text link's focus ring, small pills. */
    static let extraSmall: CGFloat = 6
    /** radius-sm, 12: category tiles, chips, inputs. */
    static let small: CGFloat = 12
    /** radius-md, 18: list cards, the formula panel, notices, accordions. */
    static let medium: CGFloat = 18
    /** radius-lg, 24: main cards and a sheet's top corners. */
    static let large: CGFloat = 24
    /** radius-xl, 30: the hero card. */
    static let extraLarge: CGFloat = 30
    /**
     radius-full: a capsule, for buttons, badges and bars; a rounded rectangle clamps it to half
     its height.
     */
    static let full: CGFloat = 9999
}

/** Sizes from the Human Interface Guidelines. */
nonisolated enum KiraSize {
    /** size-tap, 44: the smallest touch target. */
    static let tap: CGFloat = 44
    /** size-icon, 24: dock and icon-button icons. */
    static let icon: CGFloat = 24
    /** size-tile, 40: a category tile in a transaction row. */
    static let tile: CGFloat = 40
}
