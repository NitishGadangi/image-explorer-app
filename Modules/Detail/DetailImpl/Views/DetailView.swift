import SwiftUI
import MainListInterface
import CommonUIComponents

struct DetailView: View {
    @ObservedObject var viewModel: DetailViewModel
    let imageCache: ImageCache

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                RemoteImageView(url: viewModel.imageURL, cache: imageCache) {
                    Image(systemName: "photo")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, minHeight: 250)
                        .background(Color(.systemGray6))
                }
                .frame(maxWidth: .infinity)
                .frame(minHeight: 250)
                .clipShape(RoundedRectangle(cornerRadius: 12))

                if viewModel.hasTitle {
                    Text(viewModel.title)
                        .font(.title)
                        .bold()
                }

                if let description = viewModel.description {
                    Text(description)
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
        }
        .navigationTitle(viewModel.hasTitle ? viewModel.title : "Detail")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        DetailView(
            viewModel: DetailViewModel(product: .preview),
            imageCache: PreviewImageCache()
        )
    }
}

#Preview("No Description") {
    NavigationStack {
        DetailView(
            viewModel: DetailViewModel(
                product: Product(
                    team: 1, title: "Simple Product",
                    description: nil,
                    thumbnail: "https://cdn.dummyjson.com/product-images/1/thumbnail.jpg",
                    image: nil
                )
            ),
            imageCache: PreviewImageCache()
        )
    }
}
