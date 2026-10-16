import Domain
import Observation

/**
 Pilih Tanggal Gajian (ONB-10b, ONB-10c): a calendar of 1–31 with the 25th chosen at first, and
 "Gajian di akhir bulan", which dims the calendar. The button names the choice and applies it.
 */
@MainActor @Observable
package final class PaydayPickerModel {
    /** The day chosen on the calendar. */
    package private(set) var day: Int
    /** Whether "Gajian di akhir bulan" is ticked. */
    package var isEndOfMonth: Bool

    /** A picker opening on `payday`: its day, or the 25th with the box ticked for the end of the month. */
    package init(payday: Payday) {
        day = payday.day ?? Payday.defaultDay
        isEndOfMonth = payday.isEndOfMonth
    }

    /** Chooses `day` on the calendar; the calendar is off while the end of the month is ticked. */
    package func choose(_ day: Int) {
        guard !isEndOfMonth else { return }
        self.day = min(max(day, 1), 31)
    }

    /** Whether `day` shows as chosen. */
    package func isChosen(_ day: Int) -> Bool {
        !isEndOfMonth && day == self.day
    }

    /** The payday the button applies. */
    package var payday: Payday {
        isEndOfMonth ? .endOfMonth : Payday(day: day)
    }
}
