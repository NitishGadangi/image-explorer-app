import Foundation

public struct ImageCacheConfiguration: Sendable {
    public let maxItemCount: Int
    public let maxTotalSizeBytes: Int

    public init(
        maxItemCount: Int = 100,
        maxTotalSizeBytes: Int = 50_000_000
    ) {
        self.maxItemCount = maxItemCount
        self.maxTotalSizeBytes = maxTotalSizeBytes
    }
}
