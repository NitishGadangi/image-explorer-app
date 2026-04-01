import SwiftUI

public struct RemoteImageView<Placeholder: View>: View {
    private let url: URL?
    private let cache: ImageCache
    private let placeholder: () -> Placeholder

    @StateObject private var viewModel: RemoteImageViewModel

    public init(
        url: URL?,
        cache: ImageCache,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.url = url
        self.cache = cache
        self.placeholder = placeholder
        _viewModel = StateObject(wrappedValue: RemoteImageViewModel(cache: cache))
    }

    public var body: some View {
        Group {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else if viewModel.isLoading {
                ProgressView()
            } else {
                placeholder()
            }
        }
        .task(id: url) {
            await viewModel.loadImage(from: url)
        }
    }
}
