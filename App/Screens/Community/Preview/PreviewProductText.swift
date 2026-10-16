/** The detail text of the boards' four products (DetailProduk's `DATA`), as the API sends it. */
import Domain
nonisolated struct PreviewProductText {
    let description: String
    let meta: String
    let role: String
    let contentsTitle: String
    let contents: [String]

    static func of(_ kind: ProductKind) -> Self {
        switch kind {
        case .course:
            Self(
                description: "Belajar membagi gaji pertama ke pos yang jelas, tanpa rumus rumit.",
                meta: "6 modul video",
                role: "Perencana keuangan bersertifikat · 4 kelas", contentsTitle: "Yang Kamu Pelajari",
                contents: [
                    "Membagi gaji ke pos kebutuhan, tabungan, dan cicilan", "Menyusun budget per periode gajian",
                    "Mulai dana darurat dari nominal kecil", "Menjaga cicilan tetap di bawah 30% gaji",
                ])
        case .consultation:
            Self(
                description: "Didampingi menyusun permintaan keringanan ke pemberi pinjaman.",
                meta: "1 sesi · 45 menit",
                role: "Pendamping utang terverifikasi", contentsTitle: "Yang Kamu Dapatkan",
                contents: [
                    "Membaca kondisi utangmu bersama-sama", "Menyusun naskah keringanan yang realistis",
                    "Menentukan urutan pelunasan", "Rencana tindak lanjut tertulis",
                ])
        case .ebook:
            Self(
                description: "Panduan menyiapkan dana darurat untuk keluarga dengan satu atau dua penghasilan.",
                meta: "PDF · 62 halaman", role: "Penulis keuangan keluarga", contentsTitle: "Isi E-Book",
                contents: [
                    "Menghitung kebutuhan dana darurat keluarga", "Memulai dari nominal kecil tiap gajian",
                    "Memisahkan dana darurat dari tabungan lain", "Lembar kerja yang bisa dicetak",
                ])
        case .event:
            Self(
                description: "Satu sore membahas anggaran, dana darurat, dan proteksi dasar.",
                meta: "14 November 2026 · daring", role: "Penulis keuangan keluarga", contentsTitle: "Yang Dibahas",
                contents: [
                    "Menyusun anggaran keluarga satu halaman", "Menyiapkan dana darurat bertahap",
                    "Mengenal proteksi dasar tanpa istilah rumit", "Tanya jawab langsung dengan pembicara",
                ])
        }
    }
}
