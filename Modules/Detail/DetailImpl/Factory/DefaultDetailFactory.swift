import SwiftUI
import DetailInterface
import MainListInterface
import CommonUIComponents

public final class DefaultDetailFactory: DetailFactory {
    private let imageCache: ImageCache

    public init(imageCache: ImageCache) {
        self.imageCache = imageCache
    }

    @MainActor
    public func makeDetailView(for product: Product) -> AnyView {
        let viewModel = DetailViewModel(product: product)
        return AnyView(
            DetailView(viewModel: viewModel, imageCache: imageCache)
        )
    }
}
