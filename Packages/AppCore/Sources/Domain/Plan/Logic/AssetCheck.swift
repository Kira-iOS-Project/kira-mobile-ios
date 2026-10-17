import Foundation

/**
 What Tambah Aset checks before it sends (REN-11), the backend's own limits: a class chosen, a name
 of 1 to 80 characters, a value from Rp1 to Rp999.999.999.999 and a day no later than today.
 */
package enum AssetCheck {
    /** The longest name the API takes. */
    package static let maximumNameLength = 80
    /** The largest value the API takes. */
    package static let maximumValue = 999_999_999_999

    /** What is wrong with a field, as the form says it. */
    package enum Issue: Hashable, Sendable {
        /** No class is chosen. */
        case noClass
        /** The name is blank. */
        case noName
        /** The name is longer than `maximumNameLength`. */
        case nameTooLong
        /** The value is empty or zero. */
        case noValue
        /** The value is above `maximumValue`. */
        case valueTooLarge
        /** The day is after today. */
        case futureDay
    }

    /** The issues of a draft, in the form's order; empty when it can be sent. */
    package static func issues(
        assetClass: AssetClass?, name: String, value: Int?, valuedOn: CalendarDay, today: CalendarDay
    ) -> [Issue] {
        var issues: [Issue] = []
        if assetClass == nil { issues.append(.noClass) }
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            issues.append(.noName)
        } else if trimmed.count > maximumNameLength {
            issues.append(.nameTooLong)
        }
        let amount = value ?? 0
        if amount <= 0 {
            issues.append(.noValue)
        } else if amount > maximumValue {
            issues.append(.valueTooLarge)
        }
        if today < valuedOn { issues.append(.futureDay) }
        return issues
    }
}
