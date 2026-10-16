/** The score calls: the report, one indicator, saving the quiz, and every problem. */
import Domain
import Foundation
import Testing

@testable import APIClient

private struct HealthCheckBody: Decodable {
    struct Debt: Decodable { let kind: String, remaining: Int, remainingTenorMonths: Int? }
    let netMonthlyIncome: Int?
    let debts: [Debt]
    let dependents: Int
    let maritalStatus: String?
    let protections: [String]
}

@Suite("ScoreAPI")
struct ScoreAPITests {
    @Test("reads the report: score, groups, six measures and steps")
    func readsReport() async throws {
        let (api, _) = KiraAPI.canned(json: reportJSON)
        let report = try await api.getScore()
        #expect(report.score == 66 && report.band == .coping && report.delta == 4)
        #expect(report.computedAt == Date(timeIntervalSince1970: 1_792_126_800))
        #expect(report.nextCheckOn == "2026-10-25" && !report.cappedByConsumerDebt)
        #expect(report.groups[0] == GroupScoreDTO(group: .save, points: 48, band: .coping))
        let measures: [IndicatorMeasureDTO] = [
            .emergencyFund(
                ratio: 1.1, liquid: 4_800_000, essential: 4_200_000, targetMultiple: 6, targetAmount: 25_200_000),
            .savingsRatio(percent: 8, monthlySavings: 600_000, income: 7_500_000),
            .instalmentRatio(percent: 18, monthlyInstalments: 1_350_000, income: 7_500_000),
            .consumerDebt(platforms: 2, anyLate: false, anyOverdue: false),
            .debtToAsset(percent: 32, totalDebt: 14_310_000, totalAssets: 44_700_000),
            .protection(health: true, income: true),
        ]
        #expect(report.indicators.map(\.measure) == measures)
        #expect(report.indicators[4].band == .healthy && report.indicators[5].group == .protect)
        let step = try #require(report.steps.first)
        #expect(step.kind == .payOffDebt && step.debtName == "Paylater A" && step.remaining == 420_000)
        #expect(report.steps[1].targetMultiple == 3 && report.steps[1].targetPercent == nil)
    }

    @Test("reads one indicator's ladder, next rung and milestones")
    func readsIndicator() async throws {
        let (api, transport) = KiraAPI.canned(json: detailJSON)
        let detail = try await api.getScoreIndicator(.emergencyFund)
        #expect(detail.indicator.points == 50 && detail.ladder.count == 2)
        let current = LadderRungDTO(
            points: 50, lower: 1, upper: 3, amountLower: 4_200_000, amountUpper: 12_600_000, isCurrent: true)
        #expect(detail.ladder[1] == current)
        #expect(detail.nextRung == NextRungDTO(points: 75, amountNeeded: 7_800_000, scoreFrom: 66, scoreTo: 70))
        #expect(detail.milestones.last == MilestoneDTO(amount: 12_600_000, label: "3×"))
        #expect(try #require(await transport.request).path.hasSuffix("emergency_fund"))
    }

    @Test("sends the quiz's answers")
    func savesHealthCheck() async throws {
        var answers = HealthCheckInputDTO()
        answers.netMonthlyIncome = 7_500_000
        answers.payday = PaydayDTO(day: 25, endOfMonth: false)
        answers.debts = [
            HealthCheckDebtDTO(
                kind: .onlineLoan, name: "Pinjol B", remaining: 3_000_000, monthlyInstalment: 900_000,
                remainingTenorMonths: nil)
        ]
        answers.dependents = 2
        answers.maritalStatus = .married
        answers.protections = [.bpjsHealth, .lifeInsurance]
        let (api, transport) = KiraAPI.canned(json: reportJSON)
        #expect(try await api.saveHealthCheck(answers).score == 66)
        let body = try #require(await transport.request).decoded(HealthCheckBody.self)
        #expect(body.netMonthlyIncome == 7_500_000 && body.dependents == 2 && body.maritalStatus == "married")
        #expect(body.debts.first?.kind == "online_loan" && body.debts.first?.remainingTenorMonths == nil)
        #expect(body.protections == ["bpjs_health", "life_insurance"])
        #expect(HealthCheckInputDTO().debts.isEmpty && HealthCheckInputDTO().emergencyFund == nil)
    }

    @Test("refuses a measure that does not match its indicator", arguments: IndicatorKey.allCases)
    func mismatchedMeasure(key: IndicatorKey) {
        #expect(throws: AppProblem()) { try IndicatorMeasureDTO(key: key, .init()) }
    }

    @Test("throws every problem the score routes answer")
    func problems() async {
        await expectProblems([401, 404, 422]) { _ = try await $0.saveHealthCheck(HealthCheckInputDTO()) }
        await expectProblems([401, 404]) { _ = try await $0.getScore() }
        await expectProblems([401, 404, 422]) { _ = try await $0.getScoreIndicator(.protection) }
    }
}
