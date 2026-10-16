/**
 HandNote (design system): Kira's handwritten note in Kalam, like a sticky note. At most one per
 screen, three to six lowercase words without a full stop, anchored to the layout: at the end of a
 section title, under an illustration, or in the middle of the splash; never floating between two
 cards. Never for numbers, legal labels, buttons, errors or the Kira Peduli screen. Arrows are for
 onboarding and presentation boards only.
 */
import SwiftUI

/** A short handwritten note, tilted a little. */
struct KiraHandNote: View {
    /** The note's colour; each passes 4.5:1 on its background. */
    enum Tone: CaseIterable {
        /** Pandan (default). */
        case pandan
        /** The muted turmeric of the coping band. */
        case coping
        /** ink-muted. */
        case muted
        /** Turmeric on the hero card. */
        case hero
    }

    /** The note's size: t-hand (19) or t-hand-sm (16). */
    enum Size: CaseIterable {
        case medium, small
    }

    /** A hand-drawn arrow beside the note (onboarding only). */
    enum Arrow: String, CaseIterable {
        case none
        case downLeft = "down-left"
        case downRight = "down-right"
        case left, right
        case upLeft = "up-left"
        case upRight = "up-right"
    }

    private let text: LocalizedStringResource
    private let tone: Tone
    private let size: Size
    private let tilt: Double
    private let arrow: Arrow

    /** `tilt` is the rotation in degrees (-2 by default). */
    init(
        _ text: LocalizedStringResource, tone: Tone = .pandan, size: Size = .medium, tilt: Double = -2,
        arrow: Arrow = .none
    ) {
        self.text = text
        self.tone = tone
        self.size = size
        self.tilt = tilt
        self.arrow = arrow
    }

    private var color: Color {
        switch tone {
        case .pandan: .pandan
        case .coping: .coping
        case .muted: .inkMuted
        case .hero: .heroAccent
        }
    }

    private var alignment: VerticalAlignment {
        if arrow.rawValue.hasPrefix("down") { return .top }
        return arrow.rawValue.hasPrefix("up") ? .bottom : .center
    }

    private var arrowFirst: Bool { arrow.rawValue.hasSuffix("left") }

    var body: some View {
        HStack(alignment: alignment, spacing: 2) {
            if arrow != .none, arrowFirst { arrowImage }
            Text(text).kiraFont(size == .medium ? .hand : .handSmall)
            if arrow != .none, !arrowFirst { arrowImage }
        }
        .foregroundStyle(color)
        .rotationEffect(.degrees(tilt), anchor: .leading)
    }

    /** The design system draws the left-pointing arrows; the right ones are their mirror image. */
    private var arrowImage: some View {
        let left = arrow.rawValue.replacingOccurrences(of: "right", with: "left")
        return Image(decorative: "arrow-\(left)")
            .resizable()
            .frame(width: 40, height: 28)
            .scaleEffect(x: arrowFirst ? 1 : -1)
    }
}

#if DEBUG
    #Preview { GalleryNature().galleryPage() }
#endif
