import Domain

/**
 Portofolio Manual: the assets, a new one, and an asset's new figures (tag Rencana). Each answers 403
 `PLAN_FEATURE_UNAVAILABLE` outside Kira Plus.
 */
extension KiraAPI {
    /** The assets, their total and the Utang terhadap Aset indicator (`GET /api/assets`). */
    package func listAssets() async throws -> Portfolio {
        try await client.listAssets().portfolio()
    }

    /** Keeps a new asset; 422 when a figure is out of range (`POST /api/assets`). */
    package func createAsset(_ input: AssetInput) async throws -> Asset {
        try await client.createAsset(body: .json(try .init(input))).asset()
    }

    /** The asset of `id` with new figures; 404 `ASSET_NOT_FOUND` (`PATCH /api/assets/{id}`). */
    package func updateAsset(id: String, _ input: AssetInput) async throws -> Asset {
        try await client.updateAsset(path: .init(id: id), body: .json(try .init(input))).asset()
    }
}

extension Operations.ListAssets.Output {
    func portfolio() throws -> Portfolio {
        switch self {
        case .ok(let response): return try Portfolio(try response.body.json)
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .forbidden(let response): throw try response.body.applicationProblemJson
        case .default(_, let response): throw try response.body.applicationProblemJson
        }
    }
}

extension Operations.CreateAsset.Output {
    func asset() throws -> Asset {
        switch self {
        case .created(let response): return try Asset(try response.body.json)
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .forbidden(let response): throw try response.body.applicationProblemJson
        case .unprocessableContent(let response): throw try response.body.applicationProblemJson
        case .default(_, let response): throw try response.body.applicationProblemJson
        }
    }
}

extension Operations.UpdateAsset.Output {
    func asset() throws -> Asset {
        switch self {
        case .ok(let response): return try Asset(try response.body.json)
        case .unauthorized(let response): throw try response.body.applicationProblemJson
        case .forbidden(let response): throw try response.body.applicationProblemJson
        case .notFound(let response): throw try response.body.applicationProblemJson
        case .unprocessableContent(let response): throw try response.body.applicationProblemJson
        case .default(_, let response): throw try response.body.applicationProblemJson
        }
    }
}

extension Portfolio {
    /** The portfolio as the API sent it; a day this app cannot read is a problem without a code. */
    init(_ body: Components.Schemas.Portfolio) throws {
        let updatedOn = try body.updatedOn.map { text in
            guard let day = CalendarDay(iso: text) else { throw AppProblem() }
            return day
        }
        self.init(
            assets: try body.assets.map(Asset.init), total: body.total, updatedOn: updatedOn,
            debtToAsset: try body.debtToAsset.map {
                DebtToAssetImpact(percent: $0.percent, points: $0.points, band: try bridged($0.band))
            })
    }
}

extension Asset {
    init(_ body: Components.Schemas.Asset) throws {
        guard let day = CalendarDay(iso: body.valuedOn) else { throw AppProblem() }
        self.init(id: body.id, assetClass: try bridged(body.assetClass), name: body.name, value: body.value,
            valuedOn: day)
    }
}

extension Components.Schemas.AssetInput {
    init(_ input: AssetInput) throws {
        self.init(
            assetClass: try bridged(input.assetClass), name: input.name, value: input.value,
            valuedOn: input.valuedOn.iso)
    }
}

extension Components.Schemas.AssetUpdate {
    /** Every figure of the form: the update sends them all, so the asset matches what the person saw. */
    init(_ input: AssetInput) throws {
        let assetClass: AssetClassPayload = try bridged(input.assetClass)
        self.init(
            assetClass: assetClass, name: input.name, value: input.value,
            valuedOn: input.valuedOn.iso)
    }
}
