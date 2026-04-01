import SwiftUI

public protocol MainListFactory {
    @MainActor func makeMainListView() -> AnyView
}
