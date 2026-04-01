import SwiftUI
import MainListInterface
import NetworkLib
import PersistenceLib

public final class DefaultMainListCoordinator: MainListCoordinator {
    private let networkService: NetworkService
    private let persistenceService: PersistenceService
    private let onProductSelected: @MainActor (Product) -> Void

    public init(
        networkService: NetworkService,
        persistenceService: PersistenceService,
        onProductSelected: @MainActor @escaping (Product) -> Void
    ) {
        self.networkService = networkService
        self.persistenceService = persistenceService
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
            MainListView(viewModel: viewModel)
        )
    }
}
