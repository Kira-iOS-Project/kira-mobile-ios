/**
 Reads one amount from the words of a message: "30rb", "Rp 25.000", "1,5 juta", "dua puluh ribu",
 "satu setengah juta", "sejuta setengah", "goceng". Deterministic, so the same text always gives
 the same rupiah; the on-device model may rename a draft but never changes its amount.
 */
package enum AmountReader {
    /** Below this a bare number is a quantity ("2 gelas", "5 kg"), not rupiah. */
    static let minimum: Double = 100

    /**
     The amount that starts at `index` of `words` (lower case) and the index just after it, or nil
     when no amount starts there. A leading "rp" belongs to the amount.
     */
    package static func read(_ words: [String], at index: Int) -> (amount: Int, next: Int)? {
        var position = index
        if position < words.count, words[position] == "rp" { position += 1 }
        guard position < words.count else { return nil }
        if let value = AmountWords.slang[words[position]] {
            position += 1
            if position < words.count, AmountWords.slangTails.contains(words[position]) { position += 1 }
            return (Int(value), position)
        }
        var state = AmountState()
        var best: (state: AmountState, next: Int)?
        while position < words.count, let next = state.adding(AmountWords.atoms(of: words[position])) {
            state = next
            position += 1
            if state.isComplete { best = (state, position) }
        }
        guard let best, best.state.value >= minimum else { return nil }
        return (Int(best.state.value.rounded()), best.next)
    }
}

/** The running value of an amount being read, as Indonesian builds numbers. */
struct AmountState {
    /** Everything already multiplied by a scale. */
    private var total = 0.0
    /** The hundreds and tens below the next scale ("dua ratus lima puluh"). */
    private var group = 0.0
    /** The count waiting for a multiplier or a scale. */
    private var current: Double?
    /** The last scale, so the next one is smaller ("2 juta 500 ribu"). */
    private var lastScale: Double?
    private var sawScale = false

    var value: Double { total + group + (current ?? 0) }

    /**
     Whether the amount may end here: always before any scale, and after one only when nothing
     waits for the next scale, so "15rb 2 gelas" stops at 15rb.
     */
    var isComplete: Bool { !sawScale || (current == nil && group == 0) }

    /** The state after one token's atoms, or nil when the token cannot continue this amount. */
    func adding(_ atoms: [AmountAtom]) -> AmountState? {
        guard !atoms.isEmpty else { return nil }
        var state = self
        for atom in atoms {
            guard let next = state.adding(atom) else { return nil }
            state = next
        }
        return state
    }

    private func adding(_ atom: AmountAtom) -> AmountState? {
        var state = self
        switch atom {
        case .number(let count):
            guard current == nil else { return nil }
            state.current = count
        case .multiplier(let factor):
            guard let count = current else { return nil }
            state.group += count * factor
            state.current = nil
        case .teen:
            guard let count = current else { return nil }
            state.group += count + 10
            state.current = nil
        case .scale(let scale):
            return adding(scale: scale)
        case .half:
            if let lastScale, current == nil, group == 0 {
                state.total += lastScale / 2
                state.lastScale = nil
            } else {
                state.current = (current ?? 0) + 0.5
            }
        case .whole:
            return nil
        }
        return state
    }

    private func adding(scale: Double) -> AmountState? {
        let base = group + (current ?? 0)
        guard base > 0, lastScale.map({ scale < $0 }) ?? true else { return nil }
        var state = self
        state.total += base * scale
        state.group = 0
        state.current = nil
        state.lastScale = scale
        state.sawScale = true
        return state
    }
}
