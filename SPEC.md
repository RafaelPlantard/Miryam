# Miryam — v1 Spec

This document captures the original product spec that drove Miryam's v1 scope. It's kept as historical context for the constraints v1 was built against; current architecture and decisions live in [README.md](README.md) and [docs/spec-audit.md](docs/spec-audit.md).

## Description

An app to search songs through Apple's iTunes Search API based on user text input.

The v1 scope is 4 screens and 1 bottom sheet:

- Splash Screen
- Songs Screen (Home)
- Song Details (Player)
- More options bottom sheet
- Album Screen

## Must-have requirements

- Swift 6
- SwiftUI
- MVVM architecture
- Tests
- API results pagination
- Swift concurrency
- Cache using SwiftData (offline-first user experience)
  - Display the most recently played songs on the home screen
- Network abstraction layer (the API implementation should be replaceable without affecting other layers)

## Evaluation lens

- Adherence to the requirements above
- SOLID principles
- App performance and responsiveness
- Code organization
- Fidelity to the specification
- Readability, maintainability, scalability

## Extra (optional)

- Error / state handling
- Swipe to refresh
- Repository organization
- On the player screen
  - Forward / backward actions
  - Slider action to seek a specific position (song timeline must be displayed; drag-to-seek is optional)
- Accessibility

## References

- [iTunes Search API documentation](https://developer.apple.com/library/archive/documentation/AudioVideo/Conceptual/iTuneSearchAPI/Searching.html#//apple_ref/doc/uid/TP40017632-CH5-SW1)
- Design source lives in Figma under file key `L8KZBiSulfv2IEzPUQyeuq` (referenced by `CLAUDE.md` / `AGENTS.md` for AI tooling — no public link).
