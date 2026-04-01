import SwiftUI
import MainListInterface

public protocol DetailFactory {
    @MainActor func makeDetailView(for product: Product) -> AnyView
}
