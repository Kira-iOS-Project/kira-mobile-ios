import Domain
import Foundation

/** Etalase's products as `GET /api/community/products` and its detail send them (KOM-06, KOM-07). */
extension ProductSummary {
    /** A product of the list; an illustration this build does not know falls back to the kind's. */
    init(_ dto: Components.Schemas.CommunityProductSummary) throws {
        self.init(
            id: dto.id, kind: try bridged(dto.kind), title: dto.title, sellerName: dto.sellerName,
            sellerInitials: dto.sellerInitials, sellerBadge: dto.sellerBadge, price: dto.price,
            art: ProductArt(apiName: dto.icon))
    }
}

extension Product {
    /** A product in full; a seller link that is absent or not an http(s) URL is no link. */
    init(_ dto: Components.Schemas.CommunityProduct) throws {
        let detail = dto.value2
        let url = detail.sellerUrl.flatMap(URL.init(string:)).flatMap { url in
            ["https", "http"].contains(url.scheme?.lowercased() ?? "") ? url : nil
        }
        self.init(
            summary: try ProductSummary(dto.value1), description: detail.description, meta: detail.meta,
            sellerRole: detail.sellerRole, contentsTitle: detail.contentsTitle, contents: detail.contents,
            affiliate: detail.affiliate, investmentRisk: detail.investmentRisk, sellerURL: url)
    }
}
