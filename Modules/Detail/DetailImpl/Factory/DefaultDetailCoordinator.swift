import SwiftUI
import DetailInterface
import MainListInterface

public final class DefaultDetailCoordinator: DetailCoordinator {

    public init() {}

    @MainActor
    public func makeDetailView(for product: Product) -> AnyView {
        let viewModel = DetailViewModel(product: product)
        return AnyView(
            DetailView(viewModel: viewModel)
        )
    }
}
