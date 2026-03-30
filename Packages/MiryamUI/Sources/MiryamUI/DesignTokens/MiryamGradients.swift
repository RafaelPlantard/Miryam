import SwiftUI

public extension LinearGradient {
    /// Spotlight gradient — used on Splash screen background.
    /// Figma: Base/Gradients/Spotlight (60.69deg, #000000 33.57% -> #0086A0)
    static let spotlight = LinearGradient(
        stops: [
            .init(color: .black, location: 0.3357),
            .init(color: Color(hex: "0086A0"), location: 1.0)
        ],
        startPoint: UnitPoint(x: 0.28, y: 1.0),
        endPoint: UnitPoint(x: 0.72, y: 0.0)
    )
}
