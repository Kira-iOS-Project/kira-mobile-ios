/** KOM: Etalase and what it opens, on the preview service, for the audit UI tests. */
#if DEBUG
    import Domain
    import SwiftUI

    struct MarketplaceLaunch: View {
        let screen: LaunchScreen
        private let service = PreviewMarketplaceService()

        var body: some View {
            NavigationStack {
                switch screen {
                case .product: product(.course)
                case .productConsultation: product(.consultation)
                case .productEbook: product(.ebook)
                case .productEvent: product(.event)
                case .productGone: ProductScreen(id: "removed", service: service) { _ in }
                case .submitProduct: SubmitProductScreen { _ in }
                default: MarketplaceScreen(service: service) { _ in }
                }
            }
        }

        private func product(_ kind: ProductKind) -> some View {
            let id = ProductSummary.samples.first { $0.kind == kind }?.id ?? ""
            return ProductScreen(id: id, service: service) { _ in }
        }
    }
#endif
