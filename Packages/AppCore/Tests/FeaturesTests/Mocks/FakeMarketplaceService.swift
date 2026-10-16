import APIClient
import Domain
import Foundation

@testable import Features

/** The API's side of Etalase, answered from memory: the network is the boundary replaced here. */
struct FakeMarketplaceService: MarketplaceService {
    /** The list answered per kind (`nil` is "Semua"); a kind without an entry answers ROUTE_NOT_FOUND. */
    var lists: [ProductKind?: Result<[ProductSummary], AppProblem>] = [:]
    /** The detail answered for any id. */
    var detail: Result<Product, AppProblem> = .failure(AppProblem(code: "COMMUNITY_PRODUCT_NOT_FOUND"))
    /** Holds the answer for this kind until the gate opens. */
    var held: (kind: ProductKind?, gate: Gate)?

    func products(kind: ProductKind?) async throws -> [ProductSummary] {
        if let held, held.kind == kind {
            await held.gate.wait()
            try Task.checkCancellation()
        }
        return try (lists[kind] ?? .failure(AppProblem(code: "ROUTE_NOT_FOUND"))).get()
    }

    func product(id: String) throws -> Product {
        let product = try detail.get()
        guard product.summary.id == id else { throw AppProblem(code: "COMMUNITY_PRODUCT_NOT_FOUND") }
        return product
    }
}

/** A service that fails with something other than an `AppProblem`, as a lost connection does. */
struct OfflineMarketplaceService: MarketplaceService {
    func products(kind _: ProductKind?) throws -> [ProductSummary] { throw URLError(.notConnectedToInternet) }
    func product(id _: String) throws -> Product { throw URLError(.notConnectedToInternet) }
}

/** A service whose answers change between calls: each call takes the next answer in line. */
actor ScriptedMarketplaceService: MarketplaceService {
    private var lists: [Result<[ProductSummary], AppProblem>]
    private var details: [Result<Product, AppProblem>]
    /** How many times the list was asked for. */
    private(set) var listCalls = 0

    init(lists: [Result<[ProductSummary], AppProblem>] = [], details: [Result<Product, AppProblem>] = []) {
        self.lists = lists
        self.details = details
    }

    func products(kind _: ProductKind?) throws -> [ProductSummary] {
        listCalls += 1
        return try lists.removeFirst().get()
    }

    func product(id _: String) throws -> Product {
        try details.removeFirst().get()
    }
}

/** A one-time gate: `wait()` suspends until `open()`; waiting after it opened returns at once. */
actor Gate {
    private var isOpen = false
    private var waiters: [CheckedContinuation<Void, Never>] = []

    func wait() async {
        if isOpen { return }
        await withCheckedContinuation { waiters.append($0) }
    }

    func open() {
        isOpen = true
        for waiter in waiters { waiter.resume() }
        waiters.removeAll()
    }

    /** Whether someone is waiting. */
    var hasWaiter: Bool { !waiters.isEmpty }
}
