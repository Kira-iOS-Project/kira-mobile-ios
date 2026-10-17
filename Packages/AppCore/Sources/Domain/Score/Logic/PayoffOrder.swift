/**
 The order Rencana Pelunasan (SKR-03) reads from a simulation: the account paid first, the one
 before each, the month the next account starts getting the extra money ("Mulai November"), and
 the cicilan minimum, every consumer account's instalment. The days themselves come from the API.
 */
extension PayoffSimulation {
    /** The account the plan pays first ("Fokus Bulan Ini"); nil without a consumer account. */
    package var firstAccount: PayoffAccount? {
        accounts.first { $0.position == 1 }
    }

    /** The cicilan minimum: what the plan pays every month before the extra payment. */
    package var minimumInstalments: Int {
        accounts.reduce(0) { $0 + $1.monthlyInstalment }
    }

    /** The account the plan pays just before `account`; nil for the first. */
    package func previous(of account: PayoffAccount) -> PayoffAccount? {
        accounts.first { $0.position == account.position - 1 }
    }

    /** The first day of the month `account` starts getting the extra money; nil for the first, or unknown. */
    package func startMonth(of account: PayoffAccount) -> CalendarDay? {
        guard let month = previous(of: account)?.payoffMonth, let first = CalendarDay(iso: "\(month)-01") else {
            return nil
        }
        return first.adding(months: 1)
    }
}
