/**
 The five questions of Kenali Profil Risikomu (REN-06 to REN-06e), in the boards' order. Each has
 four options; an answer is the option's 0-based index as the board shows it, and the server
 scores it.
 */
package enum RiskQuestion: Int, CaseIterable, Hashable, Sendable {
    /** REN-06: the main goal of investing. */
    case goal = 1
    /** REN-06b: what the person does when the value drops 15% in a month. */
    case drawdown
    /** REN-06c: how long the money can stay untouched. */
    case horizon
    /** REN-06d: investing experience so far. */
    case experience
    /** REN-06e: the comfortable monthly deposit, in ranges of the income. */
    case monthlyDeposit

    /** How many questions there are. */
    package static let total = allCases.count
    /** How many options each question has. */
    package static let optionCount = 4

    /** "Pertanyaan N dari 5": the question's number from 1. */
    package var number: Int { rawValue }

    /** The question after this one, nil on the last. */
    package var next: Self? { Self(rawValue: rawValue + 1) }

    /** The question before this one, nil on the first. */
    package var previous: Self? { Self(rawValue: rawValue - 1) }
}
