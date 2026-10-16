import Domain
import Testing

@testable import Features

@Suite("CrisisDetector")
struct CrisisDetectorTests {
    @Test("danger from the list is final: the model is not asked")
    func listedDanger() async {
        let refiner = FakeCrisisRefiner(CrisisAssessment.none)
        let detector = CrisisDetector(refiner: refiner)
        #expect(await detector.level(of: "mending gak ada aja", allowsModel: true) == .danger)
        #expect(refiner.asked == 0)
    }

    @Test("the model may raise the list's concern to danger, never lower it")
    func raisesNeverLowers() async {
        let raising = CrisisDetector(refiner: FakeCrisisRefiner(.signal(.danger)))
        #expect(await raising.level(of: "aku udah gak kuat.", allowsModel: true) == .danger)
        let denying = CrisisDetector(refiner: FakeCrisisRefiner(CrisisAssessment.none))
        #expect(await denying.level(of: "aku udah gak kuat.", allowsModel: true) == .concern)
        let lowering = CrisisDetector(refiner: FakeCrisisRefiner(.signal(.concern)))
        #expect(await lowering.level(of: "putus asa", allowsModel: true) == .concern)
    }

    @Test("the debatable case goes to the model, which decides it")
    func debatable() async {
        let finding = FakeCrisisRefiner(.signal(.concern))
        #expect(await CrisisDetector(refiner: finding).level(of: "sedih bgt hari ini", allowsModel: true) == .concern)
        let calm = FakeCrisisRefiner(CrisisAssessment.none)
        let kopi = "capek banget hari ini beli kopi 25rb"
        #expect(await CrisisDetector(refiner: calm).level(of: kopi, allowsModel: true) == nil)
        #expect(calm.asked == 1)
    }

    @Test("the model is never asked without a cue, while AI is off, or without Indonesian")
    func modelGates() async {
        let refiner = FakeCrisisRefiner(.signal(.danger))
        let detector = CrisisDetector(refiner: refiner)
        #expect(await detector.level(of: "bensin 30rb", allowsModel: true) == nil)
        #expect(await detector.level(of: "sedih bgt", allowsModel: false) == nil)
        #expect(refiner.asked == 0)
        let foreign = FakeCrisisRefiner(.signal(.danger), knowsIndonesian: false)
        #expect(await CrisisDetector(refiner: foreign).level(of: "sedih bgt", allowsModel: true) == nil)
        #expect(foreign.asked == 0)
    }

    @Test("without a model, or when it fails, the list decides alone")
    func listAlone() async {
        #expect(await CrisisDetector(refiner: nil).level(of: "sedih bgt", allowsModel: true) == nil)
        #expect(await CrisisDetector(refiner: nil).level(of: "putus asa", allowsModel: true) == .concern)
        let failing = CrisisDetector(refiner: FakeCrisisRefiner(nil))
        #expect(await failing.level(of: "putus asa", allowsModel: true) == .concern)
    }
}
