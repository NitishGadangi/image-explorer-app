import SwiftUI
import NetworkLib
import PersistenceLib
import MainListInterface
import MainListImpl
import DetailImpl
import CentralRouter

@MainActor
final class AppFactory {
    static let shared = AppFactory()

    private var router: AppRouter?

    private init() {}

    func makeRootView() -> some View {
        let networkService = URLSessionNetworkService(
            configuration: NetworkConfiguration(
                timeout: 30,
                maxRetries: 3,
                baseBackoff: 1.0
            )
        )

        let persistenceService = DefaultPersistenceService(
            store: UserDefaultsDataStore(suiteName: "com.imageexplorer.cache")
        )

        let mainListCoordinator = DefaultMainListCoordinator(
            networkService: networkService,
            persistenceService: persistenceService,
            onProductSelected: { [weak self] product in
                self?.router?.push(.detail(product))
            }
        )

        let detailCoordinator = DefaultDetailCoordinator()

        let appRouter = AppRouter(
            mainListCoordinator: mainListCoordinator,
            detailCoordinator: detailCoordinator
        )
        router = appRouter

        return RootCoordinatorView(router: appRouter)
    }
}
