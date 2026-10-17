import APIClient
import Domain
import Features

/** The API's side of the plan, answered from memory: the network is the boundary replaced here. */
actor FakePayoffService: PayoffService {
    private(set) var calls: [PayoffCall] = []
    var answer: @Sendable (PayoffCall) throws -> PayoffSimulation = { payoffSimulation(for: $0) }

    func simulate(method: PayoffMethod, extraPayment: Int) throws -> PayoffSimulation {
        let call = PayoffCall(method: method, extraPayment: extraPayment)
        calls.append(call)
        return try answer(call)
    }

    func answers(_ answer: @escaping @Sendable (PayoffCall) throws -> PayoffSimulation) {
        self.answer = answer
    }
}

struct PayoffCall: Equatable, Sendable {
    let method: PayoffMethod
    let extraPayment: Int
}

func payoffSimulation(for call: PayoffCall) -> PayoffSimulation {
    PayoffSimulation(
        method: call.method, extraPayment: call.extraPayment, maxExtraPayment: 1_840_000, hasUnknownRate: false,
        accounts: [
            PayoffAccount(
                id: "a-1", kind: .paylater, name: "Paylater A", remaining: 420_000, monthlyInstalment: 210_000,
                position: 1, payoffMonth: "2026-11")
        ], productive: [], allPaidMonth: nil, comparison: nil)
}

/** Holds the Avalanche call with no extra payment until released, so a newer request can overtake it. */
actor GatedPayoffService: PayoffService {
    private let heldFails: Bool
    private var held: CheckedContinuation<Void, Never>?

    init(heldFails: Bool) {
        self.heldFails = heldFails
    }

    func simulate(method: PayoffMethod, extraPayment: Int) async throws -> PayoffSimulation {
        let call = PayoffCall(method: method, extraPayment: extraPayment)
        guard method == .avalanche, extraPayment == 0 else { return payoffSimulation(for: call) }
        await withCheckedContinuation { held = $0 }
        if heldFails { throw AppProblem(code: "INTERNAL_ERROR") }
        return payoffSimulation(for: call)
    }

    func untilHeld() async {
        while held == nil { await Task.yield() }
    }

    func release() {
        held?.resume()
        held = nil
    }
}
