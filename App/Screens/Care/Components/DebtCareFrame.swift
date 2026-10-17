/**
 The frame Mode Darurat Utang and its guides share (boards ModeDaruratUtang, PenagihanKasar,
 PinjolIlegal, AduanTidakSelesai, JasaPelunasan): a scrolling 16 pt column with 24 pt between
 blocks on `surface`, the soft twig leaf, 150 pt and flipped, behind the top right corner, and the
 system bar hidden for KiraNavBar with its icon-only back button.
 */
import SwiftUI

struct DebtCareFrame<Content: View>: View {
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: KiraSpacing.space6) { content }
                .padding(.horizontal, KiraSpacing.screen)
                .padding(.top, KiraSpacing.space2)
                .padding(.bottom, KiraSpacing.screenBottom)
                .frame(maxWidth: .infinity, alignment: .top)
                .background(alignment: .topTrailing) {
                    KiraLeaf(.twig, tone: .soft, size: 150, isFlipped: true)
                        .offset(x: 38, y: -28)
                        .accessibilityHidden(true)
                }
        }
        .background(.surface)
        .kiraScrollEdges()
        .toolbar(.hidden, for: .navigationBar)
    }
}
