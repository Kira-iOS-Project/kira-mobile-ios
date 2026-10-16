import Domain
import Foundation

/** Etalase's products as the board shows them. */
enum MarketplaceFixtures {
    static let course = ProductSummary(
        id: "kelas-budgeting", kind: .course, title: "Kelas Budgeting Gaji Pertama", sellerName: "Raka Aditya",
        sellerInitials: "RA", sellerBadge: "Perencana Bersertifikat", price: 149_000)
    static let consultation = ProductSummary(
        id: "negosiasi-utang", kind: .consultation, title: "Pendampingan Negosiasi Utang",
        sellerName: "Dewi Anggraini", sellerInitials: "D", sellerBadge: "Terverifikasi", price: nil)

    static let detail = Product(
        summary: course, description: "Belajar membagi gaji pertama ke pos yang jelas, tanpa rumus rumit.",
        meta: "6 modul video", sellerRole: "Perencana keuangan bersertifikat · 4 kelas",
        contentsTitle: "Yang Kamu Pelajari", contents: ["Menyusun budget per periode gajian"], affiliate: true,
        investmentRisk: false, sellerURL: URL(string: "https://penjual.example.id/kelas"))
}
