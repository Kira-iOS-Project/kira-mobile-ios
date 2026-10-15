// RupiahFormatStyle against the design system's formatRupiah: Rp10.000,00, every part, signed and hidden.
import Foundation
import Testing

@testable import Domain

@Suite("RupiahFormatStyle writes money in full with two decimals")
struct RupiahFormatStyleTests {
    struct Case: Sendable, CustomTestStringConvertible {
        let value: Decimal
        let written: String
        var testDescription: String { written }
    }

    @Test(
        "the whole amount follows the design system's formatRupiah",
        arguments: [
            Case(value: 0, written: "Rp0,00"),
            Case(value: 5, written: "Rp5,00"),
            Case(value: 999, written: "Rp999,00"),
            Case(value: 1000, written: "Rp1.000,00"),
            Case(value: 10000, written: "Rp10.000,00"),
            Case(value: 48000, written: "Rp48.000,00"),
            Case(value: 1_250_000, written: "Rp1.250.000,00"),
            Case(value: 1_840_000, written: "Rp1.840.000,00"),
            Case(value: 123_456_789, written: "Rp123.456.789,00"),
            Case(value: -10000, written: "\u{2212}Rp10.000,00"),
        ])
    func whole(_ row: Case) {
        #expect(RupiahFormatStyle().format(row.value) == row.written)
    }

    @Test(
        "cents are kept to two digits, rounded half away from zero",
        arguments: [
            Case(value: Decimal(string: "10000.5") ?? 0, written: "Rp10.000,50"),
            Case(value: Decimal(string: "10000.05") ?? 0, written: "Rp10.000,05"),
            Case(value: Decimal(string: "0.125") ?? 0, written: "Rp0,13"),
            Case(value: Decimal(string: "-0.125") ?? 0, written: "\u{2212}Rp0,13"),
            Case(value: Decimal(string: "999.995") ?? 0, written: "Rp1.000,00"),
            Case(value: Decimal(string: "-0.004") ?? 0, written: "Rp0,00"),
        ])
    func cents(_ row: Case) {
        #expect(RupiahFormatStyle().format(row.value) == row.written)
    }

    @Test("a signed amount always carries its sign, so money in and out read apart")
    func signed() {
        let style = RupiahFormatStyle.rupiah.sign(.always)
        #expect(style.format(25000) == "+Rp25.000,00")
        #expect(style.format(-25000) == "\u{2212}Rp25.000,00")
        #expect(style.format(0) == "+Rp0,00")
    }

    @Test("each part is one piece of the whole, for views that size them apart")
    func parts() {
        let style = RupiahFormatStyle().sign(.always)
        #expect(style.part(.sign).format(-1_840_000) == "\u{2212}")
        #expect(style.part(.symbol).format(-1_840_000) == "Rp")
        #expect(style.part(.integer).format(-1_840_000) == "1.840.000")
        #expect(style.part(.fraction).format(-1_840_000) == ",00")
        #expect(style.part(.whole).format(-1_840_000) == "\u{2212}Rp1.840.000,00")
    }

    @Test("a hidden balance shows Rp •••••• and gives away neither the digits nor the sign")
    func masked() {
        let style = RupiahFormatStyle().sign(.always).masked()
        #expect(style.format(1_840_000) == "Rp ••••••")
        #expect(style.part(.sign).format(-5) == "")
        #expect(style.part(.symbol).format(5) == "Rp")
        #expect(style.part(.integer).format(5) == "••••••")
        #expect(style.part(.fraction).format(5) == "")
        #expect(style.masked(false).format(5) == "+Rp5,00")
    }
}
