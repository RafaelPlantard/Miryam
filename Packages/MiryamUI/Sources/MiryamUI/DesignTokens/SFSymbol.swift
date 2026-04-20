import SwiftUI

/// Type-safe SF Symbol names used throughout the app.
public enum SFSymbol: String, Sendable {
    case musicNote = "music.note"
    case musicNoteList = "music.note.list"
    case skipBackward5 = "gobackward.5"
    case skipForward5 = "goforward.5"
    case pauseFill = "pause.fill"
    case playFill = "play.fill"
    case ellipsis
    case warningTriangle = "exclamationmark.triangle"
    case magnifyingGlass = "magnifyingglass"
    case repeatIcon = "repeat"
    case repeatOne = "repeat.1"
    case backwardEnd = "backward.end.fill"
    case forwardEnd = "forward.end.fill"
}

public extension Image {
    /// Create an Image from a type-safe SFSymbol.
    init(symbol: SFSymbol) {
        self.init(systemName: symbol.rawValue)
    }
}
