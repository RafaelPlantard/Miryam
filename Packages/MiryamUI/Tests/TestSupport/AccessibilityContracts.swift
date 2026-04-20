import Foundation
import MiryamUI

enum AccessibilityPlatform: String, CaseIterable, Sendable {
    case iphone
    case ipad
    case tvos
    case watch
}

enum AccessibilityScreen: String, CaseIterable, Sendable {
    case splash
    case songs
    case player
    case moreOptions
    case album
    case watchNowPlaying
    case watchAlbum
}

enum AccessibilityElementRole: String, Sendable {
    case any
    case container
    case button
    case textField
    case staticText
    case image
}

enum AccessibilityAuditKind: String, CaseIterable, Sendable {
    case dynamicType
    case sufficientElementDescription
    case contrast
    case hitRegion

    static let defaultRuntimeKinds: [AccessibilityAuditKind] = [
        .dynamicType,
        .sufficientElementDescription,
        .contrast,
        .hitRegion,
    ]
}

enum AccessibilityLabelRule: Hashable, Sendable, CustomStringConvertible {
    case exact(String)
    case prefix(String)
    case nonEmpty

    var description: String {
        switch self {
        case let .exact(value):
            "exact(\(value))"
        case let .prefix(value):
            "prefix(\(value))"
        case .nonEmpty:
            "nonEmpty"
        }
    }

    var isHumanReadable: Bool {
        switch self {
        case let .exact(value), let .prefix(value):
            value.trimmingCharacters(in: .whitespacesAndNewlines).count >= 3
        case .nonEmpty:
            true
        }
    }
}

enum AccessibilityLocator: Hashable, Sendable, CustomStringConvertible {
    case id(String)
    case idPrefix(String)

    var description: String {
        switch self {
        case let .id(value):
            "id(\(value))"
        case let .idPrefix(value):
            "idPrefix(\(value))"
        }
    }
}

enum AccessibilityRuntimeRoute: String, Sendable {
    case splash
    case songs
    case player
    case moreOptions
    case album
}

struct AccessibilityAuditSuppression: Hashable, Sendable {
    let descriptionContains: String
    let role: AccessibilityElementRole?
}

struct AccessibilityElementExpectation: Hashable, Sendable, CustomStringConvertible {
    let locator: AccessibilityLocator
    let role: AccessibilityElementRole
    let labelRule: AccessibilityLabelRule?
    let interactive: Bool

    var description: String {
        "\(locator) \(role.rawValue)"
    }

    var locatorKey: String {
        switch locator {
        case let .id(value):
            "id:\(value)"
        case let .idPrefix(value):
            "prefix:\(value)"
        }
    }

    var hasHumanReadableLabelRule: Bool {
        guard interactive else { return true }
        guard let labelRule else { return false }
        return labelRule.isHumanReadable
    }
}

struct AccessibilityScreenContract: Hashable, Sendable, CustomStringConvertible {
    let platform: AccessibilityPlatform
    let screen: AccessibilityScreen
    let rootIdentifier: String
    let requiredElements: [AccessibilityElementExpectation]
    let runtimeRequiredElements: [AccessibilityElementExpectation]
    let runtimeRoute: AccessibilityRuntimeRoute?
    let auditKinds: [AccessibilityAuditKind]
    let allowedSuppressions: [AccessibilityAuditSuppression]

    var description: String {
        "\(platform.rawValue)-\(screen.rawValue)"
    }

    var coverageKey: AccessibilityCoverageKey {
        AccessibilityCoverageKey(platform: platform, screen: screen)
    }

    var allLocatorKeys: [String] {
        requiredElements.map(\.locatorKey)
    }

    var runtimeLocatorKeys: [String] {
        runtimeRequiredElements.map(\.locatorKey)
    }
}

struct AccessibilityCoverageKey: Hashable, Sendable {
    let platform: AccessibilityPlatform
    let screen: AccessibilityScreen
}

enum AccessibilityContracts {
    static let all: [AccessibilityScreenContract] = [
        splash(platform: .iphone, runtimeRoute: .splash),
        songs(platform: .iphone, runtimeRoute: .songs),
        player(platform: .iphone, runtimeRoute: .player),
        moreOptions(platform: .iphone, runtimeRoute: .moreOptions),
        album(platform: .iphone, runtimeRoute: .album),

        splash(platform: .ipad, runtimeRoute: .splash),
        songs(platform: .ipad, runtimeRoute: .songs),
        player(platform: .ipad, runtimeRoute: .player),
        moreOptions(platform: .ipad, runtimeRoute: .moreOptions),
        album(platform: .ipad, runtimeRoute: .album),

        splash(platform: .tvos, runtimeRoute: nil),
        songs(platform: .tvos, runtimeRoute: nil),
        player(platform: .tvos, runtimeRoute: nil),
        moreOptions(platform: .tvos, runtimeRoute: nil),
        album(platform: .tvos, runtimeRoute: nil),

        watchNowPlaying(),
        watchAlbum(),
    ]

    static let expectedCoverage: Set<AccessibilityCoverageKey> = [
        .init(platform: .iphone, screen: .splash),
        .init(platform: .iphone, screen: .songs),
        .init(platform: .iphone, screen: .player),
        .init(platform: .iphone, screen: .moreOptions),
        .init(platform: .iphone, screen: .album),
        .init(platform: .ipad, screen: .splash),
        .init(platform: .ipad, screen: .songs),
        .init(platform: .ipad, screen: .player),
        .init(platform: .ipad, screen: .moreOptions),
        .init(platform: .ipad, screen: .album),
        .init(platform: .tvos, screen: .splash),
        .init(platform: .tvos, screen: .songs),
        .init(platform: .tvos, screen: .player),
        .init(platform: .tvos, screen: .moreOptions),
        .init(platform: .tvos, screen: .album),
        .init(platform: .watch, screen: .watchNowPlaying),
        .init(platform: .watch, screen: .watchAlbum),
    ]

    static let challengeCriticalLocators: [AccessibilityCoverageKey: Set<String>] = [
        .init(platform: .iphone, screen: .splash): [],
        .init(platform: .ipad, screen: .splash): [],
        .init(platform: .tvos, screen: .splash): [],
        .init(platform: .iphone, screen: .songs): [
            locatorKey(for: .id(AccessibilityID.songsSearchField.rawValue)),
            locatorKey(for: .idPrefix("SongRow-")),
            locatorKey(for: .id(AccessibilityID.moreOptionsButton.rawValue)),
        ],
        .init(platform: .ipad, screen: .songs): [
            locatorKey(for: .id(AccessibilityID.songsSearchField.rawValue)),
            locatorKey(for: .idPrefix("SongRow-")),
            locatorKey(for: .id(AccessibilityID.moreOptionsButton.rawValue)),
        ],
        .init(platform: .tvos, screen: .songs): [
            locatorKey(for: .id(AccessibilityID.songsSearchField.rawValue)),
            locatorKey(for: .idPrefix("SongRow-")),
            locatorKey(for: .id(AccessibilityID.moreOptionsButton.rawValue)),
        ],
        .init(platform: .iphone, screen: .player): playerCriticalLocators,
        .init(platform: .ipad, screen: .player): playerCriticalLocators,
        .init(platform: .tvos, screen: .player): playerCriticalLocators,
        .init(platform: .iphone, screen: .moreOptions): [
            locatorKey(for: .id(AccessibilityID.viewAlbumButton.rawValue)),
        ],
        .init(platform: .ipad, screen: .moreOptions): [
            locatorKey(for: .id(AccessibilityID.viewAlbumButton.rawValue)),
        ],
        .init(platform: .tvos, screen: .moreOptions): [
            locatorKey(for: .id(AccessibilityID.viewAlbumButton.rawValue)),
        ],
        .init(platform: .iphone, screen: .album): [],
        .init(platform: .ipad, screen: .album): [],
        .init(platform: .tvos, screen: .album): [],
        .init(platform: .watch, screen: .watchNowPlaying): [
            locatorKey(for: .id(AccessibilityID.skipBackward.rawValue)),
            locatorKey(for: .id(AccessibilityID.playPause.rawValue)),
            locatorKey(for: .id(AccessibilityID.skipForward.rawValue)),
        ],
        .init(platform: .watch, screen: .watchAlbum): [],
    ]

    static func contract(
        for screen: AccessibilityScreen,
        platform: AccessibilityPlatform
    ) -> AccessibilityScreenContract? {
        all.first { $0.platform == platform && $0.screen == screen }
    }

    static var runtimeAuditedScreens: [AccessibilityScreen] {
        [.splash, .songs, .player, .moreOptions, .album]
    }

    private static let playerCriticalLocators: Set<String> = [
        locatorKey(for: .id(AccessibilityID.previousTrack.rawValue)),
        locatorKey(for: .id(AccessibilityID.skipBackward.rawValue)),
        locatorKey(for: .id(AccessibilityID.playPause.rawValue)),
        locatorKey(for: .id(AccessibilityID.skipForward.rawValue)),
        locatorKey(for: .id(AccessibilityID.nextTrack.rawValue)),
    ]

    private static let playerRuntimeElements: [AccessibilityElementExpectation] = [
        .init(
            locator: .id(AccessibilityID.playPause.rawValue),
            role: .button,
            labelRule: .nonEmpty,
            interactive: true
        ),
    ]

    private static func locatorKey(for locator: AccessibilityLocator) -> String {
        switch locator {
        case let .id(value):
            "id:\(value)"
        case let .idPrefix(value):
            "prefix:\(value)"
        }
    }

    private static func splash(
        platform: AccessibilityPlatform,
        runtimeRoute: AccessibilityRuntimeRoute?
    ) -> AccessibilityScreenContract {
        AccessibilityScreenContract(
            platform: platform,
            screen: .splash,
            rootIdentifier: AccessibilityID.splashScreen.rawValue,
            requiredElements: [],
            runtimeRequiredElements: [],
            runtimeRoute: runtimeRoute,
            auditKinds: runtimeRoute == nil ? [] : AccessibilityAuditKind.defaultRuntimeKinds,
            allowedSuppressions: []
        )
    }

    private static func songs(
        platform: AccessibilityPlatform,
        runtimeRoute: AccessibilityRuntimeRoute?
    ) -> AccessibilityScreenContract {
        let requiredElements: [AccessibilityElementExpectation] = [
            .init(
                locator: .id(AccessibilityID.songsSearchField.rawValue),
                role: .textField,
                labelRule: .exact("Search"),
                interactive: true
            ),
            .init(
                locator: .idPrefix("SongRow-"),
                role: .button,
                labelRule: .nonEmpty,
                interactive: true
            ),
            .init(
                locator: .id(AccessibilityID.moreOptionsButton.rawValue),
                role: .button,
                labelRule: .prefix("More options"),
                interactive: true
            ),
        ]

        return AccessibilityScreenContract(
            platform: platform,
            screen: .songs,
            rootIdentifier: AccessibilityID.songsView.rawValue,
            requiredElements: requiredElements,
            runtimeRequiredElements: runtimeRoute == nil ? [] : requiredElements,
            runtimeRoute: runtimeRoute,
            auditKinds: runtimeRoute == nil ? [] : AccessibilityAuditKind.defaultRuntimeKinds,
            allowedSuppressions: []
        )
    }

    private static func player(
        platform: AccessibilityPlatform,
        runtimeRoute: AccessibilityRuntimeRoute?
    ) -> AccessibilityScreenContract {
        let requiredElements: [AccessibilityElementExpectation] = [
            .init(
                locator: .id(AccessibilityID.previousTrack.rawValue),
                role: .button,
                labelRule: .exact("Previous track"),
                interactive: true
            ),
            .init(
                locator: .id(AccessibilityID.skipBackward.rawValue),
                role: .button,
                labelRule: .exact("Skip backward 5 seconds"),
                interactive: true
            ),
            .init(
                locator: .id(AccessibilityID.playPause.rawValue),
                role: .button,
                labelRule: .nonEmpty,
                interactive: true
            ),
            .init(
                locator: .id(AccessibilityID.skipForward.rawValue),
                role: .button,
                labelRule: .exact("Skip forward 5 seconds"),
                interactive: true
            ),
            .init(
                locator: .id(AccessibilityID.nextTrack.rawValue),
                role: .button,
                labelRule: .exact("Next track"),
                interactive: true
            ),
        ]

        return AccessibilityScreenContract(
            platform: platform,
            screen: .player,
            rootIdentifier: AccessibilityID.playerView.rawValue,
            requiredElements: requiredElements,
            runtimeRequiredElements: runtimeRoute == nil ? [] : playerRuntimeElements,
            runtimeRoute: runtimeRoute,
            auditKinds: runtimeRoute == nil ? [] : AccessibilityAuditKind.defaultRuntimeKinds,
            allowedSuppressions: runtimeRoute == nil
                ? []
                : [
                    .init(descriptionContains: "Contrast", role: .staticText),
                    .init(descriptionContains: "no description", role: .image),
                ]
        )
    }

    private static func moreOptions(
        platform: AccessibilityPlatform,
        runtimeRoute: AccessibilityRuntimeRoute?
    ) -> AccessibilityScreenContract {
        let requiredElements: [AccessibilityElementExpectation] = [
            .init(
                locator: .id(AccessibilityID.viewAlbumButton.rawValue),
                role: .button,
                labelRule: .exact("View album"),
                interactive: true
            ),
        ]

        return AccessibilityScreenContract(
            platform: platform,
            screen: .moreOptions,
            rootIdentifier: AccessibilityID.moreOptionsSheet.rawValue,
            requiredElements: requiredElements,
            runtimeRequiredElements: runtimeRoute == nil ? [] : requiredElements,
            runtimeRoute: runtimeRoute,
            auditKinds: runtimeRoute == nil ? [] : AccessibilityAuditKind.defaultRuntimeKinds,
            allowedSuppressions: runtimeRoute == nil
                ? []
                : [
                    // ultraThinMaterial background (Figma spec) produces dynamic contrast
                    // that depends on the content behind the sheet.
                    .init(descriptionContains: "Contrast", role: nil),
                ]
        )
    }

    private static func album(
        platform: AccessibilityPlatform,
        runtimeRoute: AccessibilityRuntimeRoute?
    ) -> AccessibilityScreenContract {
        AccessibilityScreenContract(
            platform: platform,
            screen: .album,
            rootIdentifier: AccessibilityID.albumView.rawValue,
            requiredElements: [],
            runtimeRequiredElements: [],
            runtimeRoute: runtimeRoute,
            auditKinds: runtimeRoute == nil ? [] : AccessibilityAuditKind.defaultRuntimeKinds,
            allowedSuppressions: runtimeRoute == nil
                ? []
                : [
                    .init(descriptionContains: "Dynamic Type", role: nil),
                ]
        )
    }

    private static func watchNowPlaying() -> AccessibilityScreenContract {
        AccessibilityScreenContract(
            platform: .watch,
            screen: .watchNowPlaying,
            rootIdentifier: AccessibilityID.watchNowPlayingView.rawValue,
            requiredElements: [
                .init(
                    locator: .id(AccessibilityID.skipBackward.rawValue),
                    role: .button,
                    labelRule: .exact("Skip backward 5 seconds"),
                    interactive: true
                ),
                .init(
                    locator: .id(AccessibilityID.playPause.rawValue),
                    role: .button,
                    labelRule: .nonEmpty,
                    interactive: true
                ),
                .init(
                    locator: .id(AccessibilityID.skipForward.rawValue),
                    role: .button,
                    labelRule: .exact("Skip forward 5 seconds"),
                    interactive: true
                ),
            ],
            runtimeRequiredElements: [],
            runtimeRoute: nil,
            auditKinds: [],
            allowedSuppressions: []
        )
    }

    private static func watchAlbum() -> AccessibilityScreenContract {
        AccessibilityScreenContract(
            platform: .watch,
            screen: .watchAlbum,
            rootIdentifier: AccessibilityID.albumView.rawValue,
            requiredElements: [],
            runtimeRequiredElements: [],
            runtimeRoute: nil,
            auditKinds: [],
            allowedSuppressions: []
        )
    }
}
