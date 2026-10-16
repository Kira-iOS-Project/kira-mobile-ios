/**
 ProgressPita (design system): a capsule progress bar with micro milestones, for the emergency
 fund, goals, payoff plans and how much of the pay is spent. A big target is broken into reachable
 milestones (one week, one month, then multiples of essential spending). The label and its value
 sit together on the left ("Sudah terpakai · 75%"); slow progress is never brick or red.
 */
import SwiftUI

/** A progress bar with optional milestones. */
struct KiraProgressPita: View {
    /** A point on the way to the target, labelled under the bar. */
    struct Milestone: Identifiable {
        let position: Double
        let label: LocalizedStringResource
        var id: Double { position }
    }

    /** The fill's colour. */
    enum Tone: CaseIterable {
        /** Savings and goals (default). */
        case pandan
        /** A healthy outcome. */
        case sehat
    }

    private let value: Double
    private let target: Double
    private let label: LocalizedStringResource?
    private let valueLabel: LocalizedStringResource?
    private var milestones: [Milestone] = []
    private var caption: LocalizedStringResource?
    private var tone = Tone.pandan
    private var isInverse = false

    /** `valueLabel` replaces the percentage beside the label ("3 dari 6 bulan"). */
    init(
        value: Double, target: Double, label: LocalizedStringResource? = nil,
        valueLabel: LocalizedStringResource? = nil
    ) {
        self.value = value
        self.target = target
        self.label = label
        self.valueLabel = valueLabel
    }

    private var fraction: Double { target > 0 ? min(max(value / target, 0), 1) : 0 }
    private var percent: Text { Text(fraction, format: .percent.precision(.fractionLength(0))) }

    var body: some View {
        VStack(alignment: .leading, spacing: KiraSpacing.space2) {
            if let label {
                Text("ds.pita.head \(Text(label).fontWeight(.semibold)) \(valueText)")
                    .font(.subheadline)
                    .foregroundStyle(isInverse ? Color.onHero : Color.ink)
            }
            PitaTrack(fraction: fraction, ticks: milestones.map { $0.position / target }, colors: colors)
            if !milestones.isEmpty { milestoneLabels }
            if let caption {
                Text(caption).font(.footnote).foregroundStyle(isInverse ? Color.onHeroMuted : Color.inkMuted)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(label ?? "ds.pita.progress"))
        .accessibilityValue(valueLabel.map { Text($0) } ?? percent)
    }

    private var valueText: Text {
        (valueLabel.map { Text($0) } ?? percent).foregroundStyle(isInverse ? Color.onHeroMuted : Color.inkMuted)
    }

    private var colors: PitaTrack.Colors {
        if isInverse { return PitaTrack.Colors(track: .heroTrack, fill: .heroAccent) }
        return PitaTrack.Colors(track: .track, fill: tone == .sehat ? .sehat : .pandan)
    }

    private var milestoneLabels: some View {
        MilestoneLayout(places: milestones.map { $0.position / target }) {
            ForEach(milestones) { milestone in
                Text(milestone.label)
                    .font(.caption.weight(milestone.position <= value ? .semibold : .medium))
                    .foregroundStyle(milestone.position <= value ? Color.ink : Color.inkMuted)
                    .fixedSize()
            }
        }
    }

    /** The same bar with milestones under it. */
    func milestones(_ milestones: [Milestone]) -> Self { copy { $0.milestones = milestones } }

    /** The same bar with a caption under it. */
    func caption(_ text: LocalizedStringResource) -> Self { copy { $0.caption = text } }

    /** The same bar with another fill colour. */
    func tone(_ tone: Tone) -> Self { copy { $0.tone = tone } }

    /** The same bar on the hero card: a hero-track and a kunyit fill. */
    func inverse() -> Self { copy { $0.isInverse = true } }

    private func copy(_ change: (inout Self) -> Void) -> Self {
        var pita = self
        change(&pita)
        return pita
    }
}

/** The capsule track, its fill, and a dot per milestone. */
private struct PitaTrack: View {
    struct Colors {
        let track: Color
        let fill: Color
    }

    let fraction: Double
    let ticks: [Double]
    let colors: Colors

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule().fill(colors.track)
                Capsule().fill(colors.fill).frame(width: proxy.size.width * fraction)
                ForEach(ticks, id: \.self) { tick in
                    Circle()
                        .fill(tick <= fraction ? Color.onPandan : Color.inkMuted)
                        .frame(width: 4, height: 4)
                        .offset(x: proxy.size.width * tick - 2)
                }
            }
        }
        .frame(height: 10)
    }
}

/**
 Places each milestone's label under its point on the bar: left-aligned near the start,
 right-aligned near the end, centred elsewhere.
 */
private struct MilestoneLayout: Layout {
    let places: [Double]

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache _: inout ()) -> CGSize {
        var height: CGFloat = 0
        for subview in subviews {
            height = max(height, subview.sizeThatFits(.unspecified).height)
        }
        return CGSize(width: proposal.width ?? 0, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal _: ProposedViewSize, subviews: Subviews, cache _: inout ()) {
        for (subview, place) in zip(subviews, places) {
            let size = subview.sizeThatFits(.unspecified)
            let anchor: CGFloat = place > 0.85 ? size.width : (place < 0.15 ? 0 : size.width / 2)
            subview.place(
                at: CGPoint(x: bounds.minX + bounds.width * place - anchor, y: bounds.minY),
                proposal: ProposedViewSize(size))
        }
    }
}

#if DEBUG
    #Preview { GalleryProgress().galleryPage() }
#endif
