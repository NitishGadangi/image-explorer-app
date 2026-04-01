import SwiftUI

public protocol MainListCoordinator {
    @MainActor func makeMainListView() -> AnyView
}
