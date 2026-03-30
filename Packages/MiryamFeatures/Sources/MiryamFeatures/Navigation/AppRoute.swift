import MiryamCore
import SwiftUI

/// Navigation destinations.
public enum AppRoute: Hashable {
    case player(Song)
    case album(Album)
}

/// Sheets presented modally.
public enum AppSheet: Identifiable {
    case moreOptions(Song)

    public var id: String {
        switch self {
        case let .moreOptions(song): return "moreOptions-\(song.id)"
        }
    }
}
