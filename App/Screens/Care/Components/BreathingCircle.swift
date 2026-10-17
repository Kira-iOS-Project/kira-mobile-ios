/**
 Latihan Menenangkan Diri's circle (board LatihanTenang): three 260 pt rings of pandan that grow
 while the person breathes in, hold, and shrink while they breathe out, one second at a time, so a
 pause stops it where it is. With Reduce Motion the circle keeps one size and the words lead. Kuku,
 calm, breathes in its centre at the board's 170 pt, clipped by the inner circle: the owner's call
 for this exercise alone, the rest of Kira Peduli showing no Kuku.
 */
import Domain
import SwiftUI

struct BreathingCircle: View {
    let moment: BreathingPattern.Moment?
    let pattern: BreathingPattern
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            Circle().fill(.pandanSoft).opacity(0.55)
                .overlay { Circle().strokeBorder(.hairline, lineWidth: 1) }
            Circle().fill(.pandanSoft)
                .overlay { Circle().strokeBorder(.pandanLine, lineWidth: 1) }
                .padding(30)
            Circle().fill(.surfaceRaised)
                .overlay { KiraMascot(.calm, size: 170, isFramed: false) }
                .clipShape(Circle())
                .overlay { Circle().strokeBorder(.pandanLine, lineWidth: 1) }
                .padding(50)
        }
        .frame(width: 260, height: 260)
        .scaleEffect(reduceMotion ? 0.85 : scale)
        .animation(reduceMotion ? nil : .linear(duration: 1), value: scale)
        .accessibilityElement()
        .accessibilityAddTraits(.isImage)
        .accessibilityLabel(Text("care.breathing.circle"))
    }

    /**
     The size at the end of the current second: from 0.6 up to 1 over the breath in, 1 while
     holding, back down to 0.6 over the breath out; 0.6 before the start and after the end.
     */
    private var scale: CGFloat {
        guard let moment else { return 0.6 }
        let length = CGFloat(pattern.seconds(of: moment.step))
        let done = (length - CGFloat(moment.secondsLeft) + 1) / length
        switch moment.step {
        case .inhale: return 0.6 + 0.4 * done
        case .hold: return 1
        case .exhale: return 1 - 0.4 * done
        }
    }
}
