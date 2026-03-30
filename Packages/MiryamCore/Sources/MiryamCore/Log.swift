import os

/// Centralized logging namespace for the Miryam app.
///
/// Provides pre-configured loggers for each module and a factory
/// for custom categories. Subsystem is defined once here.
///
/// Usage:
/// ```swift
/// private let logger = Log.search
/// logger.info("Found \(count) results")
/// ```
public enum Log: Sendable {
    // MARK: - Subsystem

    private static let subsystem = "io.swift-yah.miryam"

    // MARK: - Module Loggers

    /// Search and song discovery (SongsViewModel).
    public static let search = Logger(subsystem: subsystem, category: "Search")

    /// Playback controls and state (PlayerViewModel).
    public static let player = Logger(subsystem: subsystem, category: "Player")

    /// Audio engine and AVPlayer lifecycle (AudioPlayer).
    public static let audio = Logger(subsystem: subsystem, category: "Audio")

    /// HTTP requests, retries, and response handling (HTTPClient).
    public static let network = Logger(subsystem: subsystem, category: "Network")

    /// SwiftData cache reads, writes, and cleanup (CacheActor).
    public static let cache = Logger(subsystem: subsystem, category: "Cache")

    // MARK: - Factory

    /// Creates a Logger for a category not covered by the predefined ones.
    /// Prefer adding a new static property above for categories used in more than one file.
    public static func logger(category: String) -> Logger {
        Logger(subsystem: subsystem, category: category)
    }
}
