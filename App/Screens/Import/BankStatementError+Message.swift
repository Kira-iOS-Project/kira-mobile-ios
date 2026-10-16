/**
 Why a statement file was refused, said as what to do next (CAT-11: "ditolak dengan pesan yang
 memberi jalan keluar"), naming the line to fix when one row is wrong.
 */
import Domain
import Foundation

extension BankStatementError {
    /** The sentence under "File Belum Bisa Dibaca". */
    var message: LocalizedStringResource {
        switch self {
        case .notText: "import.error.notText"
        case .tooLarge: "import.error.tooLarge"
        case .empty: "import.error.empty"
        case .wrongHeader: "import.error.wrongHeader"
        case .wrongColumnCount(let line): "import.error.columns \(line)"
        case .invalidDate(let line): "import.error.date \(line)"
        case .invalidAmount(let line): "import.error.amount \(line)"
        case .missingDescription(let line): "import.error.description \(line)"
        case .rangeTooLong: "import.error.range"
        case .tooManyRows: "import.error.rows"
        }
    }
}
