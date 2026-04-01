import SwiftUI
import MainListInterface
import NetworkLib
import PersistenceLib
import CommonUIComponents

struct MainListView: View {
    @StateObject var viewModel: MainListViewModel
    let imageCache: ImageCache

    init(viewModel: MainListViewModel, imageCache: ImageCache) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.imageCache = imageCache
    }

    var body: some View {
        ZStack {
            if viewModel.isLoading && viewModel.products.isEmpty {
                ProgressView("Loading products...")
            } else if let error = viewModel.errorMessage, viewModel.products.isEmpty {
                errorView(message: error)
            } else if !viewModel.searchText.isEmpty && viewModel.filteredProducts.isEmpty {
                ContentUnavailableView.search(text: viewModel.searchText)
            } else {
                productList
            }
        }
        .navigationTitle("Products")
        .searchable(text: $viewModel.searchText, prompt: "Search products")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    viewModel.selectRandomProduct()
                } label: {
                    Image(systemName: "dice")
                        .font(.title3)
                }
                .disabled(viewModel.filteredProducts.isEmpty)
            }
        }
        .refreshable {
            await viewModel.loadProducts()
        }
        .task {
            await viewModel.loadProducts()
        }
    }

    // MARK: - Subviews

    private var productList: some View {
        List(viewModel.filteredProducts) { product in
            ProductRowView(product: product, imageCache: imageCache)
                .contentShape(Rectangle())
                .onTapGesture {
                    viewModel.selectProduct(product)
                }
        }
        .listStyle(.plain)
    }

    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "wifi.slash")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text(message)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button("Retry") {
                Task {
                    await viewModel.loadProducts()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

// MARK: - Preview

private final class PreviewNetworkService: NetworkService, @unchecked Sendable {
    var configuration = NetworkConfiguration()
    func request<T: Decodable & Sendable>(endpoint: Endpoint) async throws -> T {
        throw NetworkError.noInternet
    }
}

private final class PreviewPersistenceService: PersistenceService, @unchecked Sendable {
    func save<T: Encodable>(_ object: T, forKey key: String) throws {}
    func load<T: Decodable>(forKey key: String) throws -> T? { nil }
    func delete(forKey key: String) throws {}
    func exists(forKey key: String) -> Bool { false }
}

#Preview("With Products") {
    let vm = MainListViewModel(
        networkService: PreviewNetworkService(),
        persistenceService: PreviewPersistenceService(),
        onProductSelected: { _ in }
    )
    vm.products = Product.previewList

    return NavigationStack {
        MainListView(viewModel: vm, imageCache: PreviewImageCache())
    }
}

#Preview("Loading") {
    let vm = MainListViewModel(
        networkService: PreviewNetworkService(),
        persistenceService: PreviewPersistenceService(),
        onProductSelected: { _ in }
    )
    vm.isLoading = true

    return NavigationStack {
        MainListView(viewModel: vm, imageCache: PreviewImageCache())
    }
}

#Preview("Error State") {
    let vm = MainListViewModel(
        networkService: PreviewNetworkService(),
        persistenceService: PreviewPersistenceService(),
        onProductSelected: { _ in }
    )
    vm.errorMessage = "No internet connection"

    return NavigationStack {
        MainListView(viewModel: vm, imageCache: PreviewImageCache())
    }
}
