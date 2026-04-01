import SwiftUI
import MainListInterface

public protocol DetailCoordinator {
    @MainActor func makeDetailView(for product: Product) -> AnyView
}
