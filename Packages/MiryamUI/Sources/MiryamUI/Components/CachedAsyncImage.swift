import SwiftUI

/// An image view that loads from a URL with disk + memory caching via URLCache.
///
/// Unlike `AsyncImage`, this component caches responses to disk, so scrolling
/// back to a previously-loaded image is instant without a network round-trip.
public struct CachedAsyncImage<Content: View>: View {
    private let url: URL?
    private let content: (AsyncImagePhase) -> Content

    @State private var phase: AsyncImagePhase = .empty

    public init(
        url: URL?,
        @ViewBuilder content: @escaping (AsyncImagePhase) -> Content
    ) {
        self.url = url
        self.content = content
    }

    public var body: some View {
        content(phase)
            .task(id: url) {
                await load()
            }
    }

    // MARK: - Private

    private static var cachingSession: URLSession = {
        let config = URLSessionConfiguration.default
        config.urlCache = URLCache(
            memoryCapacity: 50 * 1024 * 1024, // 50 MB
            diskCapacity: 100 * 1024 * 1024 // 100 MB
        )
        config.requestCachePolicy = .returnCacheDataElseLoad
        return URLSession(configuration: config)
    }()

    @MainActor
    private func load() async {
        guard let url else {
            phase = .empty
            return
        }

        let request = URLRequest(url: url)

        // Check cache first for instant display
        if let cached = Self.cachingSession.configuration.urlCache?.cachedResponse(for: request),
           let image = PlatformImage(data: cached.data)
        {
            phase = .success(Image(platformImage: image))
            return
        }

        // Download
        do {
            let (data, response) = try await Self.cachingSession.data(for: request)

            // Manually store if not auto-cached (some servers omit cache headers)
            let cache = Self.cachingSession.configuration.urlCache
            if cache?.cachedResponse(for: request) == nil {
                let cachedResponse = CachedURLResponse(response: response, data: data)
                cache?.storeCachedResponse(cachedResponse, for: request)
            }

            guard let image = PlatformImage(data: data) else {
                phase = .failure(URLError(.cannotDecodeContentData))
                return
            }
            phase = .success(Image(platformImage: image))
        } catch {
            phase = .failure(error)
        }
    }
}

// MARK: - Platform Image Bridging

#if canImport(UIKit)
    import UIKit

    private typealias PlatformImage = UIImage

    private extension Image {
        init(platformImage: UIImage) {
            self.init(uiImage: platformImage)
        }
    }

#elseif canImport(AppKit)
    import AppKit

    private typealias PlatformImage = NSImage

    private extension Image {
        init(platformImage: NSImage) {
            self.init(nsImage: platformImage)
        }
    }
#endif
