# Miryam

> Named after Miriam (Miryam) — Moses' sister, prophet, and musician who played the timbrel and led song after the crossing of the Red Sea (Exodus 15:20-21).
> The challenge is for [Moises.ai](https://moises.ai); Miryam is who stands next to Moses and makes music.

A multi-platform Apple music search app built as a code challenge for Moises.ai. Search the iTunes catalog, play song previews, browse albums, and keep track of recently played songs — all with offline-first caching.

## Getting Started

**Prerequisites:** Homebrew, rbenv

```bash
just bootstrap   # installs deps, generates project, opens Xcode
```

Or manually:
```bash
bundle install
mint bootstrap
mint run xcodegen generate
open Miryam.xcodeproj
```

## Architecture

```
App Target (iOS · iPadOS)
         |
    MiryamUI          — Design system, SwiftUI views, Router
         |
  MiryamFeatures      — @Observable ViewModels, DI container
         |
MiryamNetworking  MiryamPersistence  MiryamPlayer
(iTunes API)      (SwiftData cache)  (AVFoundation)
         |               |                |
              MiryamCore
   (Domain models, protocols, AppError)
```

**Dependency rule:** ViewModels depend only on protocols in MiryamCore. Concrete implementations are injected via `DependencyContainer`. No ViewModel imports Networking or Persistence directly.

## Features

- **Song Search** — Real-time search with 300ms debounce, pagination, pull-to-refresh
- **Audio Playback** — 30-second iTunes previews with play/pause, skip forward/backward, drag-to-seek timeline
- **Album View** — Browse all tracks in an album, tap to play
- **Recently Played** — Persisted via SwiftData, shown on home screen
- **Offline-First** — Search results cached; falls back to cache on network errors
- **Dark & Light Mode** — Semantic color tokens adapt automatically
- **iPad Responsive** — Adaptive artwork sizing and spacing for larger displays
- **Accessibility** — WCAG AA contrast, VoiceOver labels, 44pt tap targets, Dynamic Type

## Tech Stack

| Category | Technology |
|---|---|
| Language | Swift 6 (strict concurrency) |
| UI | SwiftUI |
| Architecture | MVVM (enforced by SPM package graph) |
| State | `@Observable`, `@MainActor` ViewModels, actors |
| Persistence | SwiftData |
| Networking | URLSession, iTunes Search API |
| Audio | AVFoundation |
| Navigation | NavigationStack + typed `AppRoute` enum |
| Font | DM Sans (Google Fonts) |
| Testing | Swift Testing, XCUITest |
| Tooling | XcodeGen, Mint, Fastlane, Just |
| CI/CD | GitHub Actions |

## Testing

143 unit tests + 8 UI tests across all packages:

| Package | Tests |
|---|---|
| MiryamCore | 61 |
| MiryamNetworking | 18 |
| MiryamPersistence | 24 |
| MiryamFeatures | 40 |
| MiryamTests (integration) | 5 |
| MiryamUITests (XCUITest) | 8 |

```bash
just test    # run all tests
just lint    # SwiftLint + SwiftFormat check
```

## Project Structure

```
Miryam/
  Miryam/                    # App target (MiryamApp.swift, Assets, Entitlements)
  MiryamTests/               # Integration tests
  MiryamUITests/             # XCUITests
  Packages/
    MiryamCore/              # Domain models, protocols, errors
    MiryamNetworking/        # iTunes API client, DTOs
    MiryamPersistence/       # SwiftData cache, offline-first
    MiryamPlayer/            # AVFoundation audio player
    MiryamFeatures/          # ViewModels, Router, DI container
    MiryamUI/                # Design system, views, components
  project.yml                # XcodeGen project definition
  justfile                   # Task runner
  fastlane/                  # Automation lanes
  .github/workflows/         # CI/CD pipelines
```

## Challenge Spec

See [CHALLENGE.md](CHALLENGE.md) for the original code challenge specification.
