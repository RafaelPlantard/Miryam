import SwiftUI

/// Registers custom DM Sans fonts from the bundle.
@MainActor
public enum FontRegistration {
    private static var isRegistered = false

    public static func registerFonts() {
        guard !isRegistered else { return }
        isRegistered = true

        let fontNames = ["DMSans-Medium", "DMSans-SemiBold"]
        for name in fontNames {
            guard let url = Bundle.module.url(forResource: name, withExtension: "ttf") else {
                continue
            }
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        }
    }
}
