import Foundation
import MainListInterface
import NetworkLib
import PersistenceLib

private let productsStorageKey = "cached_products"

@MainActor
public final class MainListViewModel: ObservableObject {
    @Published public var products: [Product] = []
    @Published public var searchText: String = ""
    @Published public var isLoading = false
    @Published public var errorMessage: String?

    private let networkService: NetworkService
    private let persistenceService: PersistenceService
    private let onProductSelected: (Product) -> Void

    public var filteredProducts: [Product] {
        guard !searchText.isEmpty else { return products }
        return products.filter {
            $0.title.localizedCaseInsensitiveContains(searchText)
        }
    }

    public init(
        networkService: NetworkService,
        persistenceService: PersistenceService,
        onProductSelected: @escaping (Product) -> Void
    ) {
        self.networkService = networkService
        self.persistenceService = persistenceService
        self.onProductSelected = onProductSelected
    }

    public func loadProducts() async {
        // 1. Load from cache first for instant UI
        loadCachedProducts()

        // 2. Fetch from network in background
        isLoading = products.isEmpty
        errorMessage = nil

        do {
            let response: ProductsResponse = try await networkService.request(
                endpoint: ProductListEndpoint()
            )
            let displayable = response.displayableProducts
            products = displayable

            // Persist for offline access
            try? persistenceService.save(displayable, forKey: productsStorageKey)
        } catch {
            // Only show error when no cached data available
            if products.isEmpty {
                errorMessage = error.localizedDescription
            }
        }

        isLoading = false
    }

    public func selectProduct(_ product: Product) {
        onProductSelected(product)
    }

    public func selectRandomProduct() {
        guard let random = filteredProducts.randomElement() else { return }
        onProductSelected(random)
    }

    // MARK: - Private

    private func loadCachedProducts() {
        guard products.isEmpty else { return }
        if let cached: [Product] = try? persistenceService.load(forKey: productsStorageKey) {
            products = cached
        }
    }
}
