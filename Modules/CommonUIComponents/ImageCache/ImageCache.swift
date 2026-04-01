import UIKit

public protocol ImageCache: Sendable {
    func image(forKey key: String) async -> UIImage?
    func store(_ image: UIImage, forKey key: String) async
    func remove(forKey key: String) async
    func clearAll() async
}

public extension ImageCache where Self == TwoTierImageCache {
    static var shared: TwoTierImageCache { .shared }
}
