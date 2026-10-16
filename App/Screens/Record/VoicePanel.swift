/**
 Input Suara (canvas InputSuara, CAT-10): the panel takes the composer's place. "Mendengarkan…",
 the waveform, the live transcript with its caret, the duration, the stop button and Batalkan; under
 it, that the audio becomes text and is deleted, and that it uses Kira Plus's voice quota.
 */
import Domain
import Features
import SwiftUI

struct VoicePanel: View {
    let model: VoiceInputModel

    var body: some View {
        VStack(spacing: KiraSpacing.space4) {
            VStack(alignment: .leading, spacing: KiraSpacing.space3) {
                status
                switch model.state {
                case .starting, .listening:
                    VoiceWaveform(levels: model.levels)
                    transcript
                case .denied:
                    Text("record.voice.denied").font(.subheadline).foregroundStyle(.inkMuted)
                case .unavailable:
                    Text("record.voice.unavailable").font(.subheadline).foregroundStyle(.inkMuted)
                }
                controls
            }
            .padding(
                EdgeInsets(
                    top: 14, leading: KiraSpacing.space4, bottom: KiraSpacing.space3, trailing: KiraSpacing.space4)
            )
            .kiraCard(.surfaceRaised, cornerRadius: 28)
            VStack(spacing: 0) {
                Text("record.voice.deleted")
                Text("record.voice.quota")
            }
            .font(.caption.weight(.medium)).kiraLineHeight(16, size: 12)
            .foregroundStyle(.inkMuted)
            .multilineTextAlignment(.center)
            .padding(.horizontal, KiraSpacing.space4)
        }
        .task { await model.start() }
    }

    private var status: some View {
        HStack(spacing: KiraSpacing.space2) {
            KiraIcon(.mic, size: 16, weight: .semibold)
                .foregroundStyle(.pandan)
                .frame(width: 28, height: 28)
                .kiraCard(.pandanSoft, border: .pandanLine, cornerRadius: 14)
                .accessibilityHidden(true)
            Text(model.state == .starting ? "record.voice.preparing" : "record.voice.listening")
                .font(.footnote.weight(.semibold)).kiraLineHeight(18, size: 13)
                .foregroundStyle(.pandan)
                .accessibilityAddTraits(.updatesFrequently)
        }
    }

    private var transcript: some View {
        HStack(alignment: .lastTextBaseline, spacing: 2) {
            Text(model.transcript).font(.body).kiraLineHeight(24, size: 17).foregroundStyle(.ink)
            RoundedRectangle(cornerRadius: 1).fill(.pandan).frame(width: 2, height: 20).accessibilityHidden(true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var controls: some View {
        HStack {
            Text(Duration.seconds(model.elapsedSeconds), format: .time(pattern: .minuteSecond))
                .font(KiraFont.display(17, .bold, relativeTo: .headline)).monospacedDigit()
                .foregroundStyle(.inkMuted)
                .padding(.leading, KiraSpacing.space2)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityLabel(Text("record.voice.duration \(model.elapsedSeconds)"))
            Button {
                Task { await model.stop() }
            } label: {
                RoundedRectangle(cornerRadius: 5).fill(.onPandan).frame(width: 20, height: 20)
                    .frame(width: 60, height: 60)
                    .background(.pandan, in: Circle())
            }
            .buttonStyle(.plain)
            .disabled(model.state != .listening)
            .accessibilityLabel(Text("record.voice.stop"))
            KiraIconButton(.close, label: "record.voice.cancel", variant: .outline) { Task { await model.cancel() } }
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(.top, KiraSpacing.space3)
        .overlay(alignment: .top) { Rectangle().fill(.line).frame(height: 1) }
    }
}

/** The waveform: the newest levels as 5 pt pandan bars, silence as short track bars. */
private struct VoiceWaveform: View {
    let levels: [Double]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(levels.indices, id: \.self) { index in
                if index > 0 { Spacer(minLength: 0) }
                Capsule()
                    .fill(levels[index] > 0 ? Color.pandan : .track)
                    .frame(width: 5, height: levels[index] > 0 ? 8 + 36 * levels[index] : 6)
            }
        }
        .frame(height: 48)
        .padding(.horizontal, 2)
        .accessibilityElement()
        .accessibilityLabel(Text("record.voice.wave"))
    }
}
