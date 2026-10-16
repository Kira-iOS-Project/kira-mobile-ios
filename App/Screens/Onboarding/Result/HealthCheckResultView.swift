/**
 Hasil Cek Kesehatan (ONB-13, ONB-13b): the first Kira Score framed gently, a plant that follows
 the band in a small garden, the three sub-scores, up to three priority steps with their points,
 the simulation label and "Gimana Ngitungnya?", closed at first. Every number is the engine's.
 */
import Domain
import Features
import SwiftUI

struct HealthCheckResultView: View {
    let flow: OnboardingFlowModel
    @State private var model: HealthCheckResultModel

    init(flow: OnboardingFlowModel, report: ScoreReport) {
        self.flow = flow
        _model = State(initialValue: flow.makeResultModel(report: report))
    }

    var body: some View {
        OnboardingPage(spacing: KiraSpacing.space5) {
            KiraNavBar("onboarding.result.title", leading: .back("onboarding.back") { flow.back() })
            ResultHero(model: model)
            HStack(alignment: .top, spacing: KiraSpacing.space2) {
                ForEach(model.groups, id: \.group) { GroupCard(score: $0) }
            }
            if !model.steps.isEmpty { ResultSteps(model: model) }
            KiraNotice(
                .simulation, title: "onboarding.result.simulation.title", message: "onboarding.result.simulation.body")
            FormulaAccordion(model: model)
            Spacer(minLength: 0)
            VStack(spacing: 10) {
                KiraButton("onboarding.result.secure") { model.continueToLock() }.block()
                Text("onboarding.result.recheck").onboardingNote().multilineTextAlignment(.center)
            }
        }
        .background(.surface)
    }
}

/** The garden, the note, the score out of 100, its band and how far the next band is. */
private struct ResultHero: View {
    let model: HealthCheckResultModel

    var body: some View {
        let report = model.report
        VStack(spacing: 14) {
            ZStack(alignment: .bottom) {
                KiraScenery(height: 150)
                KiraIllustration(.plant(for: report.band), size: 164).padding(.bottom, 22)
            }
            .frame(maxWidth: .infinity, minHeight: 214, maxHeight: 214, alignment: .bottom)
            .clipShape(RoundedRectangle(cornerRadius: KiraRadius.extraLarge, style: .continuous))
            .kiraCard(.surfaceRaised, border: .hairline, cornerRadius: KiraRadius.extraLarge)
            KiraHandNote("onboarding.result.note", tone: noteTone)
            Text("onboarding.result.overline").kiraFont(.overline).foregroundStyle(.inkMuted).padding(.top, 4)
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(report.score, format: .number).font(
                    KiraFont.display(72, .heavy, relativeTo: .largeTitle).monospacedDigit())
                Text("onboarding.result.outOf").font(KiraFont.display(17, .bold, relativeTo: .headline))
                    .foregroundStyle(.inkMuted)
            }
            .foregroundStyle(.ink)
            .padding(.top, -6)
            .accessibilityElement(children: .combine)
            KiraBandPill(report.band)
            standing.onboardingLead().multilineTextAlignment(.center).frame(maxWidth: 310)
        }
    }

    private var noteTone: KiraHandNote.Tone {
        switch model.report.band {
        case .healthy: .pandan
        case .coping: .coping
        case .vulnerable: .muted
        }
    }

    private var standing: Text {
        let band = Text(model.report.band.title)
        if let points = model.pointsToNextBand, let next = model.report.band.next {
            return Text("onboarding.result.toNext \(band) \(points) \(Text(next.title))")
        }
        return model.report.cappedByConsumerDebt
            ? Text("onboarding.result.capped") : Text("onboarding.result.top \(band)")
    }
}

/** One sub-score: its tile, name, points and band. */
private struct GroupCard: View {
    let score: GroupScore

    var body: some View {
        VStack(alignment: .leading, spacing: KiraSpacing.space2) {
            KiraCategoryIcon(category, size: 32)
            VStack(alignment: .leading, spacing: 2) {
                Text(name).kiraFont(.overline).foregroundStyle(.inkMuted)
                Text(score.points, format: .number)
                    .font(KiraFont.display(24, .heavy, relativeTo: .title2).monospacedDigit()).tracking(-0.48)
            }
            KiraBandPill(score.band, size: .small)
        }
        .padding(EdgeInsets(top: 14, leading: 12, bottom: 12, trailing: 12))
        .frame(maxWidth: .infinity, alignment: .leading)
        .kiraCard(.surfaceRaised, border: .hairline, cornerRadius: KiraRadius.medium)
        .accessibilityElement(children: .combine)
    }

    private var category: KiraCategory {
        switch score.group {
        case .save: .savings
        case .debt: .paylater
        case .protect: .protection
        }
    }

    private var name: LocalizedStringResource {
        switch score.group {
        case .save: "onboarding.result.group.save"
        case .debt: "onboarding.result.group.debt"
        case .protect: "onboarding.result.group.protect"
        }
    }
}
