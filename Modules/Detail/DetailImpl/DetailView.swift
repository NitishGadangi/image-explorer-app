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
