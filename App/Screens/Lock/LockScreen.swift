/**
 AKN-02 Kira Terkunci (board BukaKunci.dc.html): the hero green with the twig and the hills, the
 mark, "Hai lagi, <name>" and the PIN on Kira's own keypad. Buka Kira shows once six digits are in;
 until then, Lupa PIN? leads to the email check and a new PIN, keeping the data. No amounts, debt
 names, Kuku or help button. A wrong PIN says the tries left; the fifth pauses the keypad 30 s.
 */
import Features
import SwiftUI

struct LockScreen: View {
    let model: UnlockModel
    /** Builds Lupa PIN's model, or nil when the account's email is unknown. */
    let makeRecovery: () -> PinRecoveryModel?
    @State private var recovery: PinRecoveryModel?

    var body: some View {
        VStack(spacing: 0) {
            header
            Spacer(minLength: 20)
            /** The dots' row is 44 pt tall for the audit; the board's 12 and 20 pt gaps stay. */
            LockDots(filled: model.filledCount)
                .padding(.top, 12 - 16)
            LockKeypad(onDigit: model.enter, onErase: model.deleteLast)
                .padding(.top, 20 - 16)
                .disabled(isPaused)
            footer
        }
        .padding(.horizontal, KiraSpacing.screen)
        /** The board's 62 pt from the top of the screen; Lupa PIN? sits on the home indicator's inset. */
        .padding(.top, 62 - 59)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background { background }
        .fullScreenCover(item: $recovery) { PinRecoveryFlow(model: $0) }
    }

    private var header: some View {
        VStack(spacing: 10) {
            KiraLogo(.mark, tone: .hero, size: 52)
            Group {
                if let name = model.displayName {
                    Text("lock.greeting \(name)")
                } else {
                    Text("lock.greeting.anonymous")
                }
            }
            .font(KiraFont.display(26, .heavy, relativeTo: .title))
            .tracking(-0.02 * 26)
            .kiraLineHeight(32, size: 26, natural: 1.26, relativeTo: .title)
            .foregroundStyle(.onHero)
            .accessibilityAddTraits(.isHeader)
            LockStatusText(model: model)
        }
        .multilineTextAlignment(.center)
        .padding(.top, 6)
    }

    @ViewBuilder private var footer: some View {
        if model.isComplete {
            Button("lock.open", action: model.open)
                .buttonStyle(LockOpenButtonStyle())
                .frame(maxWidth: 280)
                .padding(.top, 14)
        } else {
            Button {
                recovery = makeRecovery()
            } label: {
                Text("lock.forgot")
                    .font(.subheadline.weight(.semibold))
                    .kiraLineHeight(20, size: 15)
                    .foregroundStyle(.onHeroMuted)
                    .padding(.horizontal, KiraSpacing.space4)
                    .frame(minHeight: KiraSize.tap)
                    .contentShape(Capsule())
            }
            .buttonStyle(.plain)
            .padding(.top, 6)
        }
    }

    private var background: some View {
        ZStack(alignment: .topLeading) {
            Color.hero
            /** The screen's width: the scenery at 220 pt asks for 587 pt and would push the twig off. */
            KiraScenery(tone: .hero, height: 220)
                .frame(minWidth: 0, maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            KiraLeaf(.twig, tone: .hero, size: 170).offset(x: -44, y: -24)
        }
        .ignoresSafeArea()
    }

    private var isPaused: Bool {
        if case .paused = model.phase { return true }
        return false
    }
}

/** "Masukkan PIN untuk membuka Kira", or what the last PIN met: the tries left, or the pause. */
private struct LockStatusText: View {
    let model: UnlockModel

    var body: some View {
        Group {
            switch model.phase {
            case .entering:
                Text("lock.prompt").foregroundStyle(.onHeroMuted)
            case .wrong(let remaining):
                Text("lock.wrong \(remaining)").foregroundStyle(.onHero)
            case .paused:
                TimelineView(.periodic(from: .now, by: 1)) { context in
                    Text("lock.paused \(model.secondsLeft(at: context.date))")
                        .onChange(of: model.secondsLeft(at: context.date)) { _, left in
                            if left == 0 { model.refreshPause() }
                        }
                }
                .foregroundStyle(.onHero)
            }
        }
        .font(.subheadline)
        .kiraLineHeight(20, size: 15)
        .fixedSize(horizontal: false, vertical: true)
    }
}

/** Buka Kira: the md capsule inverted on the hero green (on-hero fill, hero text). */
private struct LockOpenButtonStyle: ButtonStyle {
    @ScaledMetric(relativeTo: .headline) private var height: CGFloat = 50

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .kiraLineHeight(22, size: 17)
            .foregroundStyle(.hero)
            .padding(.horizontal, KiraSpacing.space5)
            .frame(maxWidth: .infinity, minHeight: height)
            .background(.onHero, in: Capsule())
            .capsuleHairline(.onHero)
            .opacity(configuration.isPressed ? 0.85 : 1)
            .contentShape(Capsule())
    }
}
