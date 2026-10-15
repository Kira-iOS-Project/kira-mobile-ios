/**
 The two bundled typefaces (SIL Open Font License, App/Fonts/): Plus Jakarta Sans for numbers and
 titles, Kalam for Kira's handwritten notes. Text otherwise uses SF Pro, the system font, as the
 design system's `text` family says. The fonts are registered on first use, which also covers
 Xcode previews, where the app's init never runs.
 */
import CoreText
import OSLog
import SwiftUI

/** The bundled typefaces, scaled with Dynamic Type. */
enum KiraFont {
    /**
     Plus Jakarta Sans at `size` points, scaled with Dynamic Type as `style` is.

     The file is a variable font, so `weight` picks a point on its weight axis (200–800).
     */
    static func display(_ size: CGFloat, _ weight: Font.Weight, relativeTo style: Font.TextStyle) -> Font {
        _ = registered
        return .custom("Plus Jakarta Sans", size: size, relativeTo: style).weight(weight)
    }

    /**
     Plus Jakarta Sans ExtraBold at a fixed `size`, for text drawn as part of an image (the
     wordmark), which keeps the image's proportions.
     */
    static func brand(_ size: CGFloat) -> Font {
        _ = registered
        return .custom("Plus Jakarta Sans", fixedSize: size).weight(.heavy)
    }

    /** Kalam at `size` points, scaled with Dynamic Type as `style` is. */
    static func hand(_ size: CGFloat, relativeTo style: Font.TextStyle) -> Font {
        _ = registered
        return .custom("Kalam", size: size, relativeTo: style)
    }

    private static let files = ["PlusJakartaSans-VariableFont_wght", "Kalam-Regular"]
    private static let log = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.kira", category: "fonts")

    private static let registered: Void = {
        for file in files {
            guard let url = Bundle.main.url(forResource: file, withExtension: "ttf") else {
                log.error("font file \(file, privacy: .public).ttf is missing from the bundle")
                continue
            }
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        }
    }()
}
