# Spec Audit

A requirement-to-code map for the v1 spec captured in [SPEC.md](../SPEC.md).

The implementation intentionally goes beyond the minimum spec in a few places, but the core surface remains the iPhone/iPad flow:

1. Splash
2. Songs/Home
3. Player
4. More Options sheet
5. Album

Bonus platform work on watchOS, tvOS, visionOS, and CarPlay is additive — it demonstrates architectural reach without redefining the v1 scope.

## Requirement Matrix

| Requirement | Status | Evidence |
| --- | --- | --- |
| Swift 6 | Met | `project.yml` sets `SWIFT_VERSION: "6.0"` and `SWIFT_STRICT_CONCURRENCY: complete`; all local packages use `// swift-tools-version: 6.0`. |
| SwiftUI | Met | The app entrypoints compose `SplashView`, `SongsView`, `PlayerView`, `MoreOptionsView`, and `AlbumView` from `MiryamUI`. |
| MVVM | Met | `MiryamFeatures` owns `SongsViewModel`, `PlayerViewModel`, and `AlbumViewModel`; views in `MiryamUI` bind to those types and do not talk to networking or persistence directly. |
| Tests | Met | Package unit tests, snapshot tests, accessibility audits, and smoke tests are wired through `justfile` and `.github/workflows/ci.yml`. |
| API pagination | Met | `SongsViewModel` uses `Pagination` plus `searchSongs(query:limit:offset:)`; `loadMore()` appends subsequent pages and updates `hasMorePages`. |
| Swift concurrency | Met | Networking uses async/await, `SongRepository` is an actor, `CacheActor` uses `@ModelActor`, and view models are `@Observable @MainActor`. |
| SwiftData cache / offline-first | Met | `CacheActor` stores cached search results and recently played songs in SwiftData; `SongsViewModel.search()` and `refresh()` use cache fallback on no-internet errors. |
| Recently played on home | Met | `PlayerViewModel.play(_:)` marks songs as recently played; `SongsViewModel.loadRecentlyPlayed()` hydrates the home surface. |
| Replaceable network layer | Met | `SongRepositoryProtocol` lives in `MiryamCore`; `SongRepository` is one implementation behind the DI boundary in `DependencyContainer`. |

## Tour

- Start in [README.md](../README.md) for setup and architecture.
- Use [SPEC.md](../SPEC.md) for the original v1 requirements.
- Core-flow code lives in:
  - `Miryam/MiryamApp.swift`
  - `Packages/MiryamFeatures/Sources/MiryamFeatures/ViewModels/`
  - `Packages/MiryamNetworking/Sources/MiryamNetworking/SongRepository.swift`
  - `Packages/MiryamPersistence/Sources/MiryamPersistence/CacheActor.swift`
  - `Packages/MiryamUI/Sources/MiryamUI/Views/`

## Local Verification

```bash
just lint
swift test --package-path Packages/MiryamFeatures
swift test --package-path Packages/MiryamPersistence
xcodebuild test -project Miryam.xcodeproj -scheme MiryamSmokeXCUITests -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max'
```

These commands validate the core guarantees: clean formatting/lint, search/offline-first behavior, persistence behavior, and end-to-end iOS navigation through the required flow.

## Deliberate Tradeoffs

- The repository contains extra platform surfaces and richer testing than the v1 spec requires. They are meant to show engineering discipline across the Apple platform family, not to redefine the v1 scope.
- The app favors protocol boundaries and package separation so the network and persistence layers can evolve independently without touching the views.
- Some platform-specific UI chrome remains system-owned rather than being forced to mimic static mocks where Apple frameworks are intentionally constrained.
