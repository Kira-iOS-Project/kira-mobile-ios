/**
 The category tiles' names (index.d.ts CategoryName) with the soft tint of each tile and its name
 on screen. Wallets and debts (bank, ewallet, tunai, kartu, paylater, pinjol), goals (darurat,
 rumah, pendidikan, menikah, pensiun, barang) and asset classes (bank for deposits, reksadana, sbn,
 emas, saham, kripto) share the set; a tile never stands for a product or a brand.
 */
import SwiftUI

/** A category, wallet, goal or asset class with its illustrated tile. */
enum KiraCategory: String, CaseIterable {
    case makan, transportasi, kopi, belanja, tagihan, gaji, paylater, tabungan, proteksi, rumah
    case pendidikan, kesehatan, hiburan, menikah, pensiun, bank, ewallet, tunai, kartu, pinjol
    case emas, saham, reksadana, kripto, sbn, darurat, barang, lainnya

    /** The tile's soft background (an ilu-*-muda token). */
    var tint: Color {
        switch self {
        case .makan, .tabungan, .menikah, .emas, .darurat: .iluKunyitMuda
        case .transportasi, .belanja, .gaji, .pensiun, .ewallet, .tunai, .saham, .sbn, .lainnya: .iluHijauMuda
        case .kopi, .rumah, .kesehatan, .kartu, .pinjol, .kripto, .barang: .iluPersikMuda
        case .tagihan, .paylater, .proteksi, .pendidikan, .hiburan, .bank, .reksadana: .iluLangitMuda
        }
    }

    /** The category's name on screen, Title Case. */
    var title: LocalizedStringResource {
        switch self {
        case .makan: "ds.category.makan"
        case .transportasi: "ds.category.transportasi"
        case .kopi: "ds.category.kopi"
        case .belanja: "ds.category.belanja"
        case .tagihan: "ds.category.tagihan"
        case .gaji: "ds.category.gaji"
        case .paylater: "ds.category.paylater"
        case .tabungan: "ds.category.tabungan"
        case .proteksi: "ds.category.proteksi"
        case .rumah: "ds.category.rumah"
        case .pendidikan: "ds.category.pendidikan"
        case .kesehatan: "ds.category.kesehatan"
        case .hiburan: "ds.category.hiburan"
        case .menikah: "ds.category.menikah"
        case .pensiun: "ds.category.pensiun"
        case .bank: "ds.category.bank"
        case .ewallet: "ds.category.ewallet"
        case .tunai: "ds.category.tunai"
        case .kartu: "ds.category.kartu"
        case .pinjol: "ds.category.pinjol"
        case .emas: "ds.category.emas"
        case .saham: "ds.category.saham"
        case .reksadana: "ds.category.reksadana"
        case .kripto: "ds.category.kripto"
        case .sbn: "ds.category.sbn"
        case .darurat: "ds.category.darurat"
        case .barang: "ds.category.barang"
        case .lainnya: "ds.category.lainnya"
        }
    }
}
