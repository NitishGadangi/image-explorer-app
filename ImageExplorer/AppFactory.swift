import SwiftUI
import NetworkLib
import PersistenceLib
import MainListInterface
import MainListImpl
import DetailImpl
import CentralRouter

@MainActor
enum AppFactory {
    static func makeRootView() -> some View {
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

        // Router needs to be created after coordinators, but coordinators need router reference
        // Using a class wrapper to break the circular dependency
        let routerHolder = RouterHolder()

        let mainListCoordinator = DefaultMainListCoordinator(
            networkService: networkService,
            persistenceService: persistenceService,
            onProductSelected: { product in
                routerHolder.router?.push(.detail(product))
            }
        )

        let detailCoordinator = DefaultDetailCoordinator()

        let router = AppRouter(
            mainListCoordinator: mainListCoordinator,
            detailCoordinator: detailCoordinator
        )
        routerHolder.router = router

        return RootCoordinatorView(router: router)
    }
}

@MainActor
private final class RouterHolder {
    var router: AppRouter?
}
