import SwiftUI

public struct RootCoordinatorView: View {
    @ObservedObject var router: AppRouter

    public init(router: AppRouter) {
        self.router = router
    }

    public var body: some View {
        NavigationStack(path: $router.path) {
            router.rootView()
                .navigationDestination(for: Route.self) { route in
                    router.view(for: route)
                }
        }
    }
}
