import Foundation
import SwiftData

/// Version 1 of the CachedSong schema.
/// Used by SchemaMigrationPlan to handle future model changes safely.
public enum CachedSongSchemaV1: VersionedSchema {
    public static let versionIdentifier: Schema.Version = .init(1, 0, 0)

    public static var models: [any PersistentModel.Type] {
        [CachedSong.self]
    }
}

/// Migration plan for CachedSong schema evolution.
public enum CachedSongMigrationPlan: SchemaMigrationPlan {
    public static var schemas: [any VersionedSchema.Type] {
        [CachedSongSchemaV1.self]
    }

    public static var stages: [MigrationStage] {
        []
    }
}
