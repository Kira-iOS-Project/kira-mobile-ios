/**
 IndicatorRow (design system): one of the six Kira Score indicators, in a fixed order: Dana
 Darurat, Rasio Menabung (Tabung); Rasio Cicilan, Utang Konsumtif, Utang terhadap Aset (Utang);
 Proteksi (Lindungi). The name in Title Case, the measured value in words ("1,1× pengeluaran pokok
 · target 3×"), then points, band and a 0–100 bar under it: nothing sits on the right but a
 chevron when the row opens the indicator. Group rows per sub-score in a card (KiraRowStack).
 */
import Domain
import SwiftUI

/** One Kira Score indicator. */
struct KiraIndicatorRow: View {
    private let name: Text
    private let value: Text
    private let points: Score
    private let action: (() -> Void)?
    private var target: Text?
    private var bandOverride: ScoreBand?

    /** `points` come from the score engine; with `action` the row opens the indicator's detail. */
    init(name: Text, value: Text, points: Score, action: (() -> Void)? = nil) {
        self.name = name
        self.value = value
        self.points = points
        self.action = action
    }

    private var band: ScoreBand { bandOverride ?? points.band }

    var body: some View {
        Group {
            if let action {
                Button(action: action) { content }.buttonStyle(.plain)
            } else {
                content.accessibilityElement(children: .combine)
            }
        }
        .kiraRowSeparator()
    }

    private var content: some View {
        HStack(spacing: KiraSpacing.space3) {
            VStack(alignment: .leading, spacing: 2) {
                name.font(.headline).kiraLineHeight(22, size: 17).foregroundStyle(.ink)
                valueLine.font(.subheadline).kiraLineHeight(20, size: 15).foregroundStyle(.inkMuted)
                HStack(spacing: KiraSpacing.space2) {
                    Text(points.value, format: .number)
                        .font(KiraFont.display(17, .heavy, relativeTo: .headline).monospacedDigit()).kiraLineHeight(
                            22, size: 17, natural: 1.26, relativeTo: .headline
                        )
                        .foregroundStyle(.ink)
                    KiraBandPill(band, size: .small)
                    bar
                }
                .padding(.top, 6)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            if action != nil {
                KiraIcon(.chevronRight, size: 18).foregroundStyle(.inkMuted)
            }
        }
        .padding(.vertical, KiraSpacing.space3)
        .contentShape(Rectangle())
    }

    private var valueLine: Text {
        guard let target else { return value }
        return Text("ds.indicator.value \(value) \(target)")
    }

    private var bar: some View {
        GeometryReader { proxy in
            Capsule().fill(.track)
                .overlay(alignment: .leading) {
                    Capsule().fill(band.color).frame(width: proxy.size.width * points.fraction)
                }
        }
        .frame(minWidth: 48)
        .frame(height: 6)
        .padding(.leading, KiraSpacing.space1)
        .accessibilityHidden(true)
    }

    /** The same row with its target after the value ("target 3×"). */
    func target(_ text: Text) -> Self {
        var row = self
        row.target = text
        return row
    }

    /** The same row with the band the engine sent, when it differs from the points' band. */
    func band(_ band: ScoreBand) -> Self {
        var row = self
        row.bandOverride = band
        return row
    }
}

#if DEBUG
    #Preview { GalleryScore().galleryPage() }
#endif
