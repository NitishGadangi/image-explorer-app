import SwiftUI
import MainListInterface
import DetailInterface

@MainActor
public final class AppRouter: ObservableObject {
    @Published public var path = NavigationPath()

    private let mainListCoordinator: MainListCoordinator
    private let detailCoordinator: DetailCoordinator

    public init(
        mainListCoordinator: MainListCoordinator,
        detailCoordinator: DetailCoordinator
    ) {
        self.mainListCoordinator = mainListCoordinator
        self.detailCoordinator = detailCoordinator
    }

    public func push(_ route: Route) {
        path.append(route)
    }

    public func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    @ViewBuilder
    public func rootView() -> some View {
        mainListCoordinator.makeMainListView()
    }

    @ViewBuilder
    public func view(for route: Route) -> some View {
        switch route {
        case .detail(let product):
            detailCoordinator.makeDetailView(for: product)
        }
    }
}
