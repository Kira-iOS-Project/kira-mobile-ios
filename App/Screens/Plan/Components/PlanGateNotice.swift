/**
 What Portofolio and Tambah Aset show when the API refuses them because the plan has no Portofolio
 Manual (403 `PLAN_FEATURE_UNAVAILABLE`, Kira Plus only): the notice, then Lihat Paket, as Impor
 Mutasi does.
 */
import APIClient
import SwiftUI

struct PlanGateNotice: View {
    let problem: AppProblem
    let openPlans: () -> Void

    var body: some View {
        VStack(spacing: KiraSpacing.space3) {
            KiraNotice(.warning, title: "portfolio.plusOnly.title", message: problem.message)
            KiraButton("portfolio.plans", variant: .secondary, action: openPlans).block()
        }
    }
}
