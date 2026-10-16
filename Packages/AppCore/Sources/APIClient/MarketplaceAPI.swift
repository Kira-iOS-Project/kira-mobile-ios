import Domain

/** Etalase: the curated products and one product in full (tag Community). */
extension KiraAPI {
    /** The products in the team's order, of one kind or every kind (`GET /api/community/products`). */
    package func listCommunityProducts(kind: ProductKind?) async throws -> [ProductSummary] {
        let query = Operations.ListCommunityProducts.Input.Query(kind: try bridged(kind))
        return try await client.listCommunityProducts(query: query).products()
    }

    /** One product; 404 `COMMUNITY_PRODUCT_NOT_FOUND` (`GET /api/community/products/{id}`). */
    package func getCommunityProduct(id: String) async throws -> Product {
        try await client.getCommunityProduct(path: .init(id: id)).product()
    }
}

extension Operations.ListCommunityProducts.Output {
    func products() throws -> [ProductSummary] {
        switch self {
        case .ok(let response): return try response.body.json.products.map(ProductSummary.init)
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .unprocessableContent(let response): throw try response.body.applicationProblemJson
        case .default(_, let response): throw try response.body.applicationProblemJson
        }
    }
}

extension Operations.GetCommunityProduct.Output {
    func product() throws -> Product {
        switch self {
        case .ok(let response): return try Product(try response.body.json)
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .notFound(let response): throw try response.body.applicationProblemJson
        case .unprocessableContent(let response): throw try response.body.applicationProblemJson
        case .default(_, let response): throw try response.body.applicationProblemJson
        }
    }
}
