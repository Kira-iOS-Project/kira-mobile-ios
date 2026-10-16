/**
 The lock screen's own keypad and dots (board BukaKunci.dc.html): six 12 pt dots, filled per
 digit, over a 3 × 4 grid of 70 pt round keys on the hero green, with an erase key in the corner.
 */
import SwiftUI

/** Six dots: one filled per digit typed. */
struct LockDots: View {
    let filled: Int

    var body: some View {
        HStack(spacing: 14) {
            ForEach(0..<6, id: \.self) { index in
                Circle()
                    .fill(index < filled ? Color.onHero : .clear)
                    .strokeBorder(index < filled ? Color.onHero : .onHeroMuted, lineWidth: 1.5)
                    .frame(width: 12, height: 12)
            }
        }
        .frame(minHeight: KiraSize.tap)
        /** The dots are drawn only: the keypad says how many digits are in, as its value. */
        .accessibilityHidden(true)
    }
}

/** The digits 1–9, then an empty cell, 0 and the erase key. */
struct LockKeypad: View {
    /** How many digits are in, which VoiceOver hears as the keypad's value. */
    let filled: Int
    let onDigit: (Int) -> Void
    let onErase: () -> Void
    private let rows = [[1, 2, 3], [4, 5, 6], [7, 8, 9]]

    var body: some View {
        Grid(horizontalSpacing: 28, verticalSpacing: 12) {
            ForEach(rows, id: \.self) { row in
                GridRow { ForEach(row, id: \.self) { digitKey($0) } }
            }
            GridRow {
                Color.clear.frame(width: 70, height: 70).accessibilityHidden(true)
                digitKey(0)
                Button(action: onErase) {
                    Image(systemName: "delete.left")
                        .font(.system(size: 24, weight: .light))
                        .frame(width: 70, height: 70)
                        .contentShape(Circle())
                }
                .buttonStyle(.plain)
                .foregroundStyle(.onHero)
                .accessibilityLabel(Text("lock.erase"))
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(Text("lock.keypad"))
        .accessibilityValue(Text("lock.dots \(filled)"))
    }

    private func digitKey(_ digit: Int) -> some View {
        Button {
            onDigit(digit)
        } label: {
            Text(digit, format: .number)
                .font(KiraFont.display(30, .semibold, relativeTo: .title))
                .monospacedDigit()
                .foregroundStyle(.onHero)
                .frame(width: 70, height: 70)
                .background(.heroTrack, in: Circle())
                .overlay { Circle().strokeBorder(.heroTrack, lineWidth: 1) }
                .contentShape(Circle())
        }
        .buttonStyle(LockKeyStyle())
    }
}

/** A key dims a little while pressed, with no shadow. */
private struct LockKeyStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.opacity(configuration.isPressed ? 0.6 : 1)
    }
}

#Preview {
    VStack(spacing: 20) {
        LockDots(filled: 2)
        LockKeypad(filled: 2, onDigit: { _ in }, onErase: {})
    }
    .padding()
    .background(.hero)
}
