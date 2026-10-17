/**
 PED-11, Latihan Menenangkan Diri (board LatihanTenang): breathe in 4, hold 4, breathe out 6, five
 rounds, with no score. The circle grows, holds and shrinks; the step and its count, the pattern
 with the current step in pandan, and the rounds as dots. Jeda stops the count and Lanjutkan goes
 on; Selesai, the close button and "Bicara dengan Healing119" go back to Kira Peduli. A light tap
 marks each step unless "Getaran Halus" is off, a choice kept on this phone
 (BreathingSettings).
 */
import Domain
import Features
import SwiftUI
import UIKit

struct BreathingScreen: View {
    @State private var model: BreathingExerciseModel
    @Environment(\.dismiss) private var dismiss

    init(settings: BreathingSettings = BreathingSettings()) {
        _model = State(
            initialValue: BreathingExerciseModel(
                settings: settings, tick: { try await Task.sleep(for: .seconds(1)) },
                haptic: { _ in UIImpactFeedbackGenerator(style: .light).impactOccurred() }))
    }

    var body: some View {
        VStack(spacing: KiraSpacing.space4) {
            KiraNavBar("care.breathing.title", leading: .close("care.breathing.close") { dismiss() })
            ScrollView {
                VStack(spacing: 28) {
                    BreathingCircle(moment: model.moment, pattern: model.pattern)
                    BreathingGuide(moment: model.moment, pattern: model.pattern)
                    controls
                    KiraToggle("care.breathing.haptics", isOn: haptics)
                }
                .padding(.top, KiraSpacing.space4)
            }
            KiraButton("care.breathing.healing", variant: .quiet, size: .small) { dismiss() }
        }
        .padding(.horizontal, KiraSpacing.screen)
        .padding(.top, KiraSpacing.space2)
        .background(alignment: .topTrailing) {
            KiraLeaf(.twig, tone: .soft, size: 160, isFlipped: true).offset(x: 40, y: -22).accessibilityHidden(true)
        }
        .background(alignment: .bottomLeading) {
            KiraLeaf(.pandan, tone: .soft, size: 112).offset(x: -58, y: 18).accessibilityHidden(true)
        }
        .background(.surface)
        .toolbar(.hidden, for: .navigationBar)
        .task { await model.run() }
    }

    /** Jeda (Lanjutkan while paused) beside Selesai; only Selesai once the rounds are done. */
    private var controls: some View {
        HStack(spacing: KiraSpacing.space3) {
            if !model.isFinished {
                KiraIconButton(
                    model.isPaused ? .play : .pause,
                    label: model.isPaused ? "care.breathing.resume" : "care.breathing.pause", variant: .outline
                ) { model.togglePause() }
            }
            KiraButton("care.breathing.done", variant: .secondary, size: .small) { dismiss() }
        }
    }

    private var haptics: Binding<Bool> {
        Binding(
            get: { model.hapticsOn },
            set: { isOn in
                if isOn != model.hapticsOn { model.toggleHaptics() }
            })
    }
}

#if DEBUG
    #Preview {
        NavigationStack { BreathingScreen() }
    }
#endif
