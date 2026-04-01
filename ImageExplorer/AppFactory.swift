import SwiftUI
import NetworkLib
import PersistenceLib
import CommonUIComponents
import MainListInterface
import MainListImpl
import DetailInterface
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

        let imageCache = TwoTierImageCache(
            memory: InMemoryImageCache(
                config: ImageCacheConfiguration(
                    maxItemCount: 50,
                    maxTotalSizeBytes: 25_000_000
                )
            ),
            persistent: PersistentImageCache(
                config: ImageCacheConfiguration(
                    maxItemCount: 200,
                    maxTotalSizeBytes: 100_000_000
                )
            )
        )

        // Router needs to be created after factories, but factories need router reference
        // Using a class wrapper to break the circular dependency
        let routerHolder = RouterHolder()

        let mainListFactory = DefaultMainListFactory(
            networkService: networkService,
            persistenceService: persistenceService,
            imageCache: imageCache,
            onProductSelected: { product in
                routerHolder.router?.push(.detail(product))
            }
        )

        let detailFactory = DefaultDetailFactory(imageCache: imageCache)

        let router = AppRouter(
            mainListFactory: mainListFactory,
            detailFactory: detailFactory
        )
        routerHolder.router = router

        return RootCoordinatorView(router: router)
    }
}

@MainActor
private final class RouterHolder {
    var router: AppRouter?
}
