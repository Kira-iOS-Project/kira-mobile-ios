/** KOM: Etalase and what it opens, on the preview service, for the audit UI tests. */
#if DEBUG
    import APIClient
    import Domain
    import Features
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
                case .marketplaceEmpty:
                    MarketplaceScreen(service: AnsweringMarketplaceService(answer: .success([]))) { _ in }
                case .marketplaceFailed:
                    MarketplaceScreen(service: AnsweringMarketplaceService(answer: .failure(.connectionLost))) { _ in }
                default: MarketplaceScreen(service: service) { _ in }
                }
            }
        }

        private func product(_ kind: ProductKind) -> some View {
            ProductScreen(id: ProductSummary.sample(kind).id, service: service) { _ in }
        }
    }

    /** Etalase answering one list for every kind: none at all, or a lost connection. */
    private struct AnsweringMarketplaceService: MarketplaceService {
        let answer: Result<[ProductSummary], AppProblem>

        func products(kind _: ProductKind?) throws -> [ProductSummary] { try answer.get() }
        func product(id: String) async throws -> Product { try await PreviewMarketplaceService().product(id: id) }
    }
#endif
