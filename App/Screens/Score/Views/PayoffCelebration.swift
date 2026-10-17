/**
 Perayaan Lunas (SKR-05, board PerayaanLunas): the full screen that opens once, when a payment
 settles an account. Kuku proud, the instalment that leaves the month, and the score the engine
 expects; then Lanjut ke the next account (which moves the plan there) or, when it was the last
 one, Lihat Kira Score; Ke Beranda under it. No confetti, sound, streak or countdown.
 */
import Domain
import Features
import SwiftUI

/** Where the person leaves the celebration for. */
enum CelebrationExit: Hashable {
    /** Lanjut ke the next account: back on Rencanaku, the plan moved there. */
    case next(PaidOffAccount)
    /** Ke Beranda, or the close button. */
    case home
    /** Lihat Kira Score, after the last account. */
    case score
}

struct PayoffCelebration: View {
    let paid: PaidOffAccount
    /** Closes the screen; the caller goes on to `exit` once it has gone. */
    let onExit: (CelebrationExit) -> Void

    var body: some View {
        VStack(spacing: KiraSpacing.space4) {
            HStack {
                KiraIconButton.close("plan.celebrate.close") { onExit(.home) }
                Spacer(minLength: 0)
            }
            .frame(minHeight: KiraSize.tap)
            ScrollView {
                VStack(spacing: KiraSpacing.space5) {
                    VStack(spacing: KiraSpacing.space1) {
                        KiraMascot(.proud, size: 210)
                        KiraHandNote("plan.celebrate.note", tilt: -2).accessibilityHidden(true)
                    }
                    words
                    if let estimate = paid.scoreEstimate {
                        PaidOffScoreCard(estimate: estimate)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, KiraSpacing.space2)
            }
            .scrollBounceBehavior(.basedOnSize)
            .defaultScrollAnchor(.center)
            actions
        }
        .padding(.horizontal, KiraSpacing.screen)
        .padding(.top, KiraSpacing.space2)
        .padding(.bottom, KiraSpacing.space2)
        .background { backdrop }
    }

    private var words: some View {
        VStack(spacing: KiraSpacing.space2) {
            if let position = PayoffPlanCopy.position(paid) {
                Text(position).kiraFont(.overline).kiraSmallType().foregroundStyle(.pandan)
            }
            Text("plan.celebrate.title \(paid.name)")
                .font(KiraFont.display(30, axisWeight: 800, relativeTo: .largeTitle, typeSize: typeSize))
                .kiraLineHeight(36, size: 30, relativeTo: .largeTitle)
                .tracking(-0.75)
                .foregroundStyle(.ink)
                .accessibilityAddTraits(.isHeader)
            Text("plan.celebrate.body \(PayoffCopy.rupiah(paid.monthlyInstalment))")
                .font(.body).kiraLineHeight(24, size: 17).foregroundStyle(.inkMuted)
                .frame(maxWidth: 310)
        }
        .multilineTextAlignment(.center)
    }

    @ViewBuilder private var actions: some View {
        VStack(spacing: KiraSpacing.space2) {
            if let next = paid.nextAccount {
                KiraButton("plan.celebrate.continue \(next.name)") { onExit(.next(paid)) }.block()
            } else {
                KiraButton("plan.celebrate.scoreCta") { onExit(.score) }.block()
            }
            KiraButton("plan.celebrate.home", variant: .secondary) { onExit(.home) }.block()
        }
    }

    /** The leaves behind the top right and the left, and the scenery along the bottom. */
    private var backdrop: some View {
        ZStack {
            Color.surface
            KiraLeaf(.twig, tone: .soft, size: 140, isFlipped: true)
                .offset(x: 40, y: -22)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            KiraLeaf(.pandan, tone: .soft, size: 110)
                .offset(x: -44, y: 188)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            KiraScenery(height: 180)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        }
        .ignoresSafeArea()
        .accessibilityHidden(true)
    }

    @Environment(\.dynamicTypeSize) private var typeSize
}

/** Perkiraan Kira Score: before → after, the points gained and the band it lands in. */
private struct PaidOffScoreCard: View {
    let estimate: ScoreEstimate
    @Environment(\.dynamicTypeSize) private var typeSize

    /** "66 → 71"; "Kira Score tetap 36" when the score does not move. */
    private var scoreLine: LocalizedStringResource {
        estimate.after == estimate.before
            ? "plan.celebrate.score.same \(estimate.after)" : "plan.celebrate.score \(estimate.before) \(estimate.after)"
    }

    var body: some View {
        HStack(spacing: 14) {
            KiraIllustration(.growing, size: 56)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 16, style: .continuous).strokeBorder(Color.hairline, lineWidth: 1)
                }
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: KiraSpacing.space1) {
                Text("plan.celebrate.score.title")
                    .font(.footnote.weight(.semibold)).kiraLineHeight(18, size: 13).foregroundStyle(.inkMuted)
                Text(scoreLine)
                    .font(KiraFont.display(26, axisWeight: 800, relativeTo: .title, typeSize: typeSize))
                    .kiraLineHeight(32, size: 26, relativeTo: .title)
                    .tracking(-0.52)
                    .monospacedDigit()
                    .foregroundStyle(.ink)
                KiraFlowRow(spacing: KiraSpacing.space2) {
                    if estimate.after > estimate.before {
                        KiraTag(
                            "plan.celebrate.points \(estimate.after - estimate.before)", tone: .healthy, icon: .trendUp)
                    }
                    KiraBandPill(ScoreBand(score: estimate.after), size: .small)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(EdgeInsets(top: 14, leading: 14, bottom: 14, trailing: 16))
        .frame(maxWidth: .infinity, alignment: .leading)
        .kiraCard()
        .accessibilityElement(children: .combine)
    }
}
