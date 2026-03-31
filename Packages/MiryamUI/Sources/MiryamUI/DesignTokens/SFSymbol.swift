import SwiftUI

/// Type-safe SF Symbol names used throughout the app.
public enum SFSymbol: String, Sendable {
    case musicNote = "music.note"
    case musicNoteList = "music.note.list"
    case skipBackward15 = "gobackward.15"
    case skipForward15 = "goforward.15"
    case pauseFill = "pause.fill"
    case playFill = "play.fill"
    case ellipsis
    case warningTriangle = "exclamationmark.triangle"
    case magnifyingGlass = "magnifyingglass"
    case repeatIcon = "repeat"
    case repeatOne = "repeat.1"
}

public extension Image {
    /// Create an Image from a type-safe SFSymbol.
    init(symbol: SFSymbol) {
        self.init(systemName: symbol.rawValue)
    }
}
