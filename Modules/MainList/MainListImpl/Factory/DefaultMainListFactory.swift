import SwiftUI
import MainListInterface
import NetworkLib
import PersistenceLib
import CommonUIComponents

public final class DefaultMainListFactory: MainListFactory {
    private let networkService: NetworkService
    private let persistenceService: PersistenceService
    private let imageCache: ImageCache
    private let onProductSelected: @MainActor (Product) -> Void

    public init(
        networkService: NetworkService,
        persistenceService: PersistenceService,
        imageCache: ImageCache,
        onProductSelected: @MainActor @escaping (Product) -> Void
    ) {
        self.networkService = networkService
        self.persistenceService = persistenceService
        self.imageCache = imageCache
        self.onProductSelected = onProductSelected
    }

    @MainActor
    public func makeMainListView() -> AnyView {
        let viewModel = MainListViewModel(
            networkService: networkService,
            persistenceService: persistenceService,
            onProductSelected: onProductSelected
        )
        return AnyView(
            MainListView(viewModel: viewModel, imageCache: imageCache)
        )
    }
}
