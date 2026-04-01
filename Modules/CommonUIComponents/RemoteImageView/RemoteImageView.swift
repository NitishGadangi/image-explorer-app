import SwiftUI

public struct RemoteImageView<Placeholder: View>: View {
    private let url: URL?
    private let cache: ImageCache
    private let placeholder: () -> Placeholder

    @StateObject private var viewModel: RemoteImageViewModel

    public init(
        url: URL?,
        cache: ImageCache = .shared,
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

#Preview("With URL") {
    RemoteImageView(
        url: URL(string: "https://cdn.dummyjson.com/product-images/1/thumbnail.jpg")
    ) {
        Image(systemName: "photo")
            .foregroundStyle(.secondary)
    }
    .frame(width: 120, height: 120)
    .clipShape(RoundedRectangle(cornerRadius: 12))
}

#Preview("No URL") {
    RemoteImageView(url: nil) {
        Image(systemName: "photo")
            .foregroundStyle(.secondary)
    }
    .frame(width: 120, height: 120)
    .clipShape(RoundedRectangle(cornerRadius: 12))
}
