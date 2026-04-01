import UIKit

/// A no-op image cache for SwiftUI previews
public actor PreviewImageCache: ImageCache {
    public init() {}

    public func image(forKey key: String) -> UIImage? { nil }
    public func store(_ image: UIImage, forKey key: String) {}
    public func remove(forKey key: String) {}
    public func clearAll() {}
}
