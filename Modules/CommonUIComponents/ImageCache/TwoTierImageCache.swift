import UIKit

public final class TwoTierImageCache: ImageCache, @unchecked Sendable {
    private let memory: ImageCache
    private let persistent: ImageCache

    public init(memory: ImageCache, persistent: ImageCache) {
        self.memory = memory
        self.persistent = persistent
    }

    public func image(forKey key: String) async -> UIImage? {
        // Check memory first
        if let cached = await memory.image(forKey: key) {
            return cached
        }

        // Check disk, promote to memory on hit
        if let cached = await persistent.image(forKey: key) {
            await memory.store(cached, forKey: key)
            return cached
        }

        return nil
    }

    public func store(_ image: UIImage, forKey key: String) async {
        await memory.store(image, forKey: key)
        await persistent.store(image, forKey: key)
    }

    public func remove(forKey key: String) async {
        await memory.remove(forKey: key)
        await persistent.remove(forKey: key)
    }

    public func clearAll() async {
        await memory.clearAll()
        await persistent.clearAll()
    }
}
