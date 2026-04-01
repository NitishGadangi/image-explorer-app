import SwiftUI
import MainListInterface
import CommonUIComponents

struct ProductRowView: View {
    let product: Product

    var body: some View {
        HStack(spacing: 12) {
            RemoteImageView(url: product.displayThumbnailURL) {
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

#Preview {
    List {
        ProductRowView(product: .preview)
        ProductRowView(
            product: Product(
                team: 1, title: "A product with a longer title to test line wrapping",
                description: nil, thumbnail: nil, image: nil
            )
        )
    }
    .listStyle(.plain)
}
