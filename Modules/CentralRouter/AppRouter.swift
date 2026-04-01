import SwiftUI
import MainListInterface
import DetailInterface

@MainActor
public final class AppRouter: ObservableObject {
    @Published public var path = NavigationPath()

    private let mainListFactory: MainListFactory
    private let detailFactory: DetailFactory

    public init(
        mainListFactory: MainListFactory,
        detailFactory: DetailFactory
    ) {
        self.mainListFactory = mainListFactory
        self.detailFactory = detailFactory
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
        mainListFactory.makeMainListView()
    }

    @ViewBuilder
    public func view(for route: Route) -> some View {
        switch route {
        case .detail(let product):
            detailFactory.makeDetailView(for: product)
        }
    }
}
