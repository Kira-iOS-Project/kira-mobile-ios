import APIClient
import Domain

/** The Rencana Pelunasan screen's call over the API client. */
package struct LivePayoffService: PayoffService {
    private let api: KiraAPI

    /** Calls through `api`. */
    package init(api: KiraAPI) {
        self.api = api
    }

    /** `POST /payoff/simulate`. */
    package func simulate(method: PayoffMethod, extraPayment: Int) async throws -> PayoffSimulation {
        let dto: PayoffMethodDTO = try Bridge.value(method)
        return try PayoffSimulation(try await api.simulatePayoff(method: dto, extraPayment: extraPayment))
    }
}
