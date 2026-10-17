import Testing

@testable import Domain

/** Kalkulator Dana Darurat and its Hasil Simulasi boards. */
@Suite("EmergencyFund")
struct EmergencyFundTests {
    private func fund(
        married: Bool = false, dependants: Int = 0, months: Int = 30, present: Int = 4_800_000, deposit: Int = 650_000,
        annualReturn: Double = 0.04
    ) -> EmergencyFund {
        EmergencyFund(
            monthlyEssential: 4_200_000, married: married, dependants: dependants, months: months, present: present,
            deposit: deposit, annualReturn: annualReturn)
    }

    @Test("Rp4.200.000 × 6 = Rp25.200.000; Rp650.000 a month at 4% for 30 months is Cocok, 50:50")
    func persona() {
        let persona = fund()
        #expect(persona.multiplier == 6 && persona.target == 25_200_000 && persona.half == 12_600_000)
        let plan = persona.projection
        #expect(plan.result == 25_844_674 && plan.principal == 24_300_000 && plan.fit == .fits)
        #expect(persona.recommendations.isEmpty)
    }

    @Test("9× married, 3× more per dependant, at most 15×")
    func multiplier() {
        #expect(fund(married: true).multiplier == 9)
        #expect(fund(dependants: 1).multiplier == 9)
        #expect(fund(married: true, dependants: 3).multiplier == 15)
        #expect(fund(dependants: -1).multiplier == 6)
    }

    @Test("short: Naikkan Investasi and more months; a plan that never gets there offers no months")
    func short() {
        let found = fund(months: 12).recommendations
        guard case .raiseDeposit = found.first, case .extendMonths(let months) = found.last else {
            return #expect(Bool(false))
        }
        #expect(months > 12 && found.count == 2)
        let never = fund(present: 0, deposit: 0, annualReturn: 0).recommendations
        #expect(never.count == 1)
    }
}
