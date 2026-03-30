import Foundation
import SwiftData

/// Creates the SwiftData ModelContainer for the app.
public enum PersistenceContainer {
    /// Shared container for production use.
    public static func makeContainer() throws -> ModelContainer {
        let schema = Schema([CachedSong.self])
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )
        return try ModelContainer(for: schema, configurations: [configuration])
    }

    /// In-memory container for testing.
    public static func makeTestContainer() throws -> ModelContainer {
        let schema = Schema([CachedSong.self])
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true
        )
        return try ModelContainer(for: schema, configurations: [configuration])
    }
}
