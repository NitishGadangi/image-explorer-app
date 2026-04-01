import UIKit

public actor InMemoryImageCache: ImageCache {
    private let cache = NSCache<NSString, UIImage>()
    private let config: ImageCacheConfiguration

    public init(config: ImageCacheConfiguration = ImageCacheConfiguration()) {
        self.config = config
        cache.countLimit = config.maxItemCount
        cache.totalCostLimit = config.maxTotalSizeBytes
    }

    public func image(forKey key: String) -> UIImage? {
        cache.object(forKey: key as NSString)
    }

    public func store(_ image: UIImage, forKey key: String) {
        let cost = image.jpegData(compressionQuality: 1.0)?.count ?? 0
        cache.setObject(image, forKey: key as NSString, cost: cost)
    }

    public func remove(forKey key: String) {
        cache.removeObject(forKey: key as NSString)
    }

    public func clearAll() {
        cache.removeAllObjects()
    }
}
