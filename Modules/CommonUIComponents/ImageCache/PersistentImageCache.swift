import UIKit
import CryptoKit

public actor PersistentImageCache: ImageCache {
    private let cacheDirectory: URL
    private let config: ImageCacheConfiguration
    private let fileManager = FileManager.default

    public init(
        config: ImageCacheConfiguration = ImageCacheConfiguration(),
        directoryName: String = "ImageCache"
    ) {
        self.config = config
        let caches = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        self.cacheDirectory = caches.appendingPathComponent(directoryName)

        if !fileManager.fileExists(atPath: cacheDirectory.path) {
            try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        }
    }

    public func image(forKey key: String) -> UIImage? {
        let fileURL = fileURL(forKey: key)
        guard let data = try? Data(contentsOf: fileURL) else { return nil }

        // Update access date for LRU
        try? fileManager.setAttributes(
            [.modificationDate: Date()],
            ofItemAtPath: fileURL.path
        )

        return UIImage(data: data)
    }

    public func store(_ image: UIImage, forKey key: String) {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return }
        let fileURL = fileURL(forKey: key)
        try? data.write(to: fileURL)
        evictIfNeeded()
    }

    public func remove(forKey key: String) {
        let fileURL = fileURL(forKey: key)
        try? fileManager.removeItem(at: fileURL)
    }

    public func clearAll() {
        try? fileManager.removeItem(at: cacheDirectory)
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }

    // MARK: - Private

    private func fileURL(forKey key: String) -> URL {
        let hash = SHA256.hash(data: Data(key.utf8))
        let filename = hash.compactMap { String(format: "%02x", $0) }.joined()
        return cacheDirectory.appendingPathComponent(filename)
    }

    private func evictIfNeeded() {
        guard let files = try? fileManager.contentsOfDirectory(
            at: cacheDirectory,
            includingPropertiesForKeys: [.fileSizeKey, .contentModificationDateKey]
        ) else { return }

        var totalSize = 0
        var fileInfos: [(url: URL, size: Int, date: Date)] = []

        for file in files {
            let values = try? file.resourceValues(forKeys: [.fileSizeKey, .contentModificationDateKey])
            let size = values?.fileSize ?? 0
            let date = values?.contentModificationDate ?? .distantPast
            totalSize += size
            fileInfos.append((url: file, size: size, date: date))
        }

        guard fileInfos.count > config.maxItemCount || totalSize > config.maxTotalSizeBytes else {
            return
        }

        // Sort by modification date ascending (oldest first) for LRU eviction
        fileInfos.sort { $0.date < $1.date }

        var currentCount = fileInfos.count
        var currentSize = totalSize

        for info in fileInfos {
            guard currentCount > config.maxItemCount || currentSize > config.maxTotalSizeBytes else {
                break
            }
            try? fileManager.removeItem(at: info.url)
            currentCount -= 1
            currentSize -= info.size
        }
    }
}
