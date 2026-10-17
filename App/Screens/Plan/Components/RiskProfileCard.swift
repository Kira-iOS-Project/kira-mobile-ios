/**
 Hasil Kuis's card: the stairs rising out of its top edge, "Profil risikomu", the profile in the
 large title, its sentence, and the scale of three, the person's step in pandan. VoiceOver reads the
 scale as one sentence ("Skala profil risiko: Konservatif, Moderat, Agresif. Kamu di Moderat.").
 */
import Domain
import SwiftUI

struct RiskProfileCard: View {
    let profile: RiskProfile

    var body: some View {
        VStack(spacing: 14) {
            KiraIllustration(.stairs, size: 120).padding(.top, -84)
            VStack(spacing: 2) {
                Text("plan.result.overline").kiraFont(.overline).foregroundStyle(.pandan)
                Text(profile.title).kiraFont(.largeTitle).foregroundStyle(.ink).accessibilityAddTraits(.isHeader)
            }
            Text(profile.sentence)
                .font(.subheadline).kiraLineHeight(21, size: 15).foregroundStyle(.inkMuted)
                .multilineTextAlignment(.center).frame(maxWidth: 300)
                .fixedSize(horizontal: false, vertical: true)
            scale
        }
        .padding(EdgeInsets(top: 24, leading: 20, bottom: 20, trailing: 20))
        .frame(maxWidth: .infinity)
        .kiraCard(.surfaceRaised, cornerRadius: KiraRadius.large)
    }

    private var scale: some View {
        HStack(alignment: .top, spacing: 6) {
            ForEach(RiskProfile.allCases, id: \.self) { step in
                VStack(spacing: 6) {
                    Capsule().fill(step == profile ? Color.pandan : Color.track).frame(height: 8)
                    Text(step.title)
                        .font(.caption.weight(step == profile ? .bold : .medium)).kiraLineHeight(16, size: 12)
                        .foregroundStyle(step == profile ? Color.ink : Color.inkMuted)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.top, 6)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("plan.result.scale \(String(localized: profile.title))"))
    }
}
