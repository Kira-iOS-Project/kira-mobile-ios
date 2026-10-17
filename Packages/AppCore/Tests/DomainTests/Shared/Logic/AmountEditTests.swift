import Testing

@testable import Domain

/** Types `keys` one by one at the caret, as a person does, starting from an empty field. */
private func typed(_ keys: String) -> AmountEdit {
    keys.reduce(AmountEdit(text: "", caret: 0)) { edit, key in
        AmountEdit.apply(to: edit.text, location: edit.caret, length: 0, replacement: String(key))
    }
}

@Suite("AmountEdit")
struct AmountEditTests {
    @Test("every digit typed in a row is kept, grouped as it goes, the caret at the end")
    func typesInARow() {
        #expect(typed("7500000") == AmountEdit(text: "7.500.000", caret: 9))
        #expect(typed("4800000") == AmountEdit(text: "4.800.000", caret: 9))
        #expect(typed("999999999999").text == "999.999.999.999")
    }

    @Test("a digit typed in the middle keeps the caret after it")
    func typesInTheMiddle() {
        /** The caret after "7.5", "2" typed: the digits 7, 5, 2, 0, 0 read "75.200", the caret after "75.2". */
        #expect(
            AmountEdit.apply(to: "7.500", location: 3, length: 0, replacement: "2")
                == AmountEdit(text: "75.200", caret: 4))
    }

    @Test("backspace removes a digit, also when the caret sits after a dot")
    func deletes() {
        #expect(
            AmountEdit.apply(to: "7.500.000", location: 8, length: 1, replacement: "")
                == AmountEdit(text: "750.000", caret: 7))
        #expect(
            AmountEdit.apply(to: "7.500", location: 1, length: 1, replacement: "")
                == AmountEdit(text: "500", caret: 0))
        #expect(AmountEdit.apply(to: "5", location: 0, length: 1, replacement: "") == AmountEdit(text: "", caret: 0))
    }

    @Test("a paste keeps only its digits, and leading zeros go")
    func pastes() {
        #expect(
            AmountEdit.apply(to: "", location: 0, length: 0, replacement: "Rp18.000")
                == AmountEdit(text: "18.000", caret: 6))
        #expect(typed("05") == AmountEdit(text: "5", caret: 1))
        #expect(typed("0") == AmountEdit(text: "0", caret: 1))
        #expect(
            AmountEdit.apply(to: "", location: 0, length: 0, replacement: "abc") == AmountEdit(text: "", caret: 0))
    }

    @Test("past twelve digits the field stays as it was; a range past the end is clamped")
    func limits() {
        let full = typed("999999999999")
        #expect(
            AmountEdit.apply(to: full.text, location: full.caret, length: 0, replacement: "9")
                == AmountEdit(text: full.text, caret: full.caret))
        #expect(
            AmountEdit.apply(to: "500", location: 9, length: 4, replacement: "1")
                == AmountEdit(text: "5.001", caret: 5))
        #expect(
            AmountEdit.apply(to: "500", location: -2, length: -1, replacement: "1")
                == AmountEdit(text: "1.500", caret: 1))
    }

    @Test("a late echo of an older value never takes digits from a field being typed in")
    func staleEcho() {
        #expect(AmountEdit.shown(current: "48.000", binding: "4.800", isEditing: true) == "48.000")
        #expect(AmountEdit.shown(current: "7.500.000", binding: "750000", isEditing: true) == "7.500.000")
        #expect(AmountEdit.shown(current: "48.000", binding: "4800000", isEditing: false) == "4.800.000")
        #expect(AmountEdit.shown(current: "48.000", binding: "", isEditing: false) == "")
    }
}
