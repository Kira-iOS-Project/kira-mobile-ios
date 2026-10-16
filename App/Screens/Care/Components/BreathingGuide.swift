/**
 The words under Latihan Menenangkan Diri's circle (board LatihanTenang): the step and its count in
 52 pt pandan figures, the calm line, the pattern with the current step in pandan, and the rounds as
 five dots with "Putaran 2 dari 5". Once the rounds are done, "Latihan Selesai" in their place.
 */
import Domain
import SwiftUI

struct BreathingGuide: View {
    let moment: BreathingPattern.Moment?
    let pattern: BreathingPattern

    var body: some View {
        VStack(spacing: KiraSpacing.space3) {
            if let moment {
                HStack(alignment: .firstTextBaseline, spacing: 10) {
                    Text(Self.name(of: moment.step))
                        .font(.title3.weight(.semibold)).kiraLineHeight(26, size: 20).foregroundStyle(.inkMuted)
                    Text(moment.secondsLeft, format: .number)
                        .font(KiraFont.display(52, .heavy, relativeTo: .largeTitle))
                        .monospacedDigit().tracking(-1).foregroundStyle(.pandan)
                }
                .accessibilityElement(children: .combine)
            } else {
                Text("care.breathing.finished")
                    .font(.title3.weight(.semibold)).kiraLineHeight(26, size: 20).foregroundStyle(.inkMuted)
            }
            Text("care.breathing.calm")
                .font(.subheadline).kiraLineHeight(20, size: 15).foregroundStyle(.inkMuted)
            steps
            if let moment { rounds(moment.round) }
        }
        .multilineTextAlignment(.center)
    }

    /** "Tarik 4 · Tahan 4 · Hembuskan 6", the current step strong and in pandan. */
    private var steps: some View {
        let parts = BreathingPattern.Step.allCases.map { step in
            var part = AttributedString(localized: Self.short(of: step, seconds: pattern.seconds(of: step)))
            if step == moment?.step {
                part.foregroundColor = .pandan
                part.inlinePresentationIntent = .stronglyEmphasized
            }
            return part
        }
        var line = parts[0]
        for part in parts.dropFirst() { line += AttributedString(" · ") + part }
        return Text(line).font(.body).kiraLineHeight(22, size: 17).foregroundStyle(.inkMuted)
    }

    private func rounds(_ round: Int) -> some View {
        HStack(spacing: 10) {
            HStack(spacing: 6) {
                ForEach(1...pattern.rounds, id: \.self) { index in
                    Circle().fill(index <= round ? Color.pandan : Color.track).frame(width: 8, height: 8)
                }
            }
            .accessibilityHidden(true)
            Text("care.breathing.round \(round) \(pattern.rounds)")
                .font(.footnote.weight(.semibold)).kiraLineHeight(18, size: 13).foregroundStyle(.inkMuted)
        }
    }

    /** "Tarik napas", "Tahan", "Hembuskan". */
    static func name(of step: BreathingPattern.Step) -> LocalizedStringResource {
        switch step {
        case .inhale: "care.breathing.inhale"
        case .hold: "care.breathing.hold"
        case .exhale: "care.breathing.exhale"
        }
    }

    private static func short(of step: BreathingPattern.Step, seconds: Int) -> LocalizedStringResource {
        switch step {
        case .inhale: "care.breathing.inhale.short \(seconds)"
        case .hold: "care.breathing.hold.short \(seconds)"
        case .exhale: "care.breathing.exhale.short \(seconds)"
        }
    }
}
