import UIKit

@MainActor
public final class RemoteImageViewModel: ObservableObject {
    @Published public var image: UIImage?
    @Published public var isLoading = false

    private let cache: ImageCache
    private var currentURL: URL?

    public init(cache: ImageCache) {
        self.cache = cache
    }

    public func loadImage(from url: URL?) async {
        guard let url else {
            image = nil
            return
        }

        // Avoid reloading the same URL
        guard url != currentURL else { return }
        currentURL = url

        let cacheKey = url.absoluteString

        // Check cache first
        if let cached = await cache.image(forKey: cacheKey) {
            image = cached
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let downloaded = UIImage(data: data) else { return }

            await cache.store(downloaded, forKey: cacheKey)

            // Only update if URL hasn't changed while loading
            if currentURL == url {
                image = downloaded
            }
        } catch {
            // Silently fail — placeholder will remain visible
        }
    }
}
