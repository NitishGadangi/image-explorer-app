import SwiftUI
import MainListInterface
import CommonUIComponents

struct ProductRowView: View {
    let product: Product
    let imageCache: ImageCache

    var body: some View {
        HStack(spacing: 12) {
            RemoteImageView(url: product.displayThumbnailURL, cache: imageCache) {
                Image(systemName: "photo")
                    .foregroundStyle(.secondary)
            }
            .frame(width: 60, height: 60)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            Text(product.title)
                .font(.body)
                .lineLimit(2)

            Spacer()
        }
        .padding(.vertical, 4)
    }
}
