import Foundation
import MainListInterface

@MainActor
public final class DetailViewModel: ObservableObject {
    public let product: Product

    public init(product: Product) {
        self.product = product
    }

    public var imageURL: URL? {
        product.displayImageURL
    }

    public var title: String {
        product.title
    }

    public var description: String? {
        product.description
    }

    public var hasTitle: Bool {
        !product.title.isEmpty
    }
}
