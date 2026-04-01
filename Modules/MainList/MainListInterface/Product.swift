import Foundation

public struct Product: Codable, Identifiable, Hashable, Sendable {
    public let id: UUID
    public let team: Int
    public let title: String
    public let description: String?
    public let thumbnail: String?
    public let image: String?

    enum CodingKeys: String, CodingKey {
        case team, title, description, thumbnail, image
    }

    public init(
        id: UUID = UUID(),
        team: Int,
        title: String,
        description: String?,
        thumbnail: String?,
        image: String?
    ) {
        self.id = id
        self.team = team
        self.title = title
        self.description = description
        self.thumbnail = thumbnail
        self.image = image
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID()
        self.team = try container.decode(Int.self, forKey: .team)
        self.title = try container.decode(String.self, forKey: .title)
        self.description = try container.decodeIfPresent(String.self, forKey: .description)
        self.thumbnail = try container.decodeIfPresent(String.self, forKey: .thumbnail)
        self.image = try container.decodeIfPresent(String.self, forKey: .image)
    }

    // MARK: - Computed Properties

    /// Best available thumbnail URL (thumbnail first, fallback to image)
    public var displayThumbnailURL: URL? {
        if let thumbnail, !thumbnail.isEmpty {
            return URL(string: thumbnail)
        }
        if let image, !image.isEmpty {
            return URL(string: image)
        }
        return nil
    }

    /// Best available full image URL (image first, fallback to thumbnail)
    public var displayImageURL: URL? {
        if let image, !image.isEmpty {
            return URL(string: image)
        }
        if let thumbnail, !thumbnail.isEmpty {
            return URL(string: thumbnail)
        }
        return nil
    }

    /// Whether this product has at least one valid image to display
    public var isDisplayable: Bool {
        displayThumbnailURL != nil
    }

    // MARK: - Hashable (by id only, since id is generated client-side)

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: Product, rhs: Product) -> Bool {
        lhs.id == rhs.id
    }
}

public struct ProductsResponse: Codable, Sendable {
    public let products: [Product?]

    /// Filtered to only displayable, non-nil products
    public var displayableProducts: [Product] {
        products.compactMap { $0 }.filter { $0.isDisplayable }
    }
}
