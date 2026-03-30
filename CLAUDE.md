# Miryam — AI Agent Instructions

## Project Context

Miryam is a multi-platform Apple music search app built as a code challenge for [Moises.ai](https://moises.ai).
Named after Miriam (Miryam) — Moses' sister, prophet and musician who played the timbrel and led song after the crossing of the Red Sea (Exodus 15:20–21). The challenge is for Moises.ai; Miryam is who stands next to Moses and makes music.

**Stack:** Swift 6 · SwiftUI · SwiftData · MVVM · 6 local SPM packages · XcodeGen · Fastlane · GitHub Actions
**Bundle ID:** io.swift-yah.miryam
**Design spec:** `docs/superpowers/plans/` — read the current wave plan before starting any implementation.
**Figma file key:** `L8KZBiSulfv2IEzPUQyeuq` — use Figma MCP tools for every screen implementation.

## Workflow Orchestration

### 1. Plan Mode Default
- Enter plan mode for ANY non-trivial task (3+ steps or architectural decisions)
- If something goes sideways, STOP and re-plan immediately
- Use plan mode for verification steps, not just building
- Write detailed specs upfront to reduce ambiguity

### 2. Subagent Strategy
- Use subagents liberally to keep main context window clean
- Offload research, exploration, and parallel analysis to subagents
- For complex problems, throw more compute at it via subagents
- One task per subagent for focused execution

### 3. Self-Improvement Loop
- After ANY correction from the user: update memory with the pattern
- Write rules for yourself that prevent the same mistake
- Ruthlessly iterate on these lessons until mistake rate drops
- Review memory at session start for relevant project context

### 4. Verification Before Done
- Never mark a task complete without proving it works
- Diff behavior between main and your changes when relevant
- Ask yourself: "Would a staff engineer approve this?"
- Run tests, check logs, demonstrate correctness

### 5. Demand Elegance (Balanced)
- For non-trivial changes: pause and ask "is there a more elegant way?"
- If a fix feels hacky: "Knowing everything I know now, implement the elegant solution"
- Skip this for simple, obvious fixes — don't over-engineer
- Challenge your own work before presenting it

### 6. Autonomous Bug Fixing
- When given a bug report: just fix it. Don't ask for hand-holding
- Point at logs, errors, failing tests — then resolve them
- Zero context switching required from the user
- Go fix failing CI tests without being told how

## Task Management
1. **Plan First**: Write plan to tasks/todo.md with checkable items
2. **Verify Plan**: Check in before starting implementation
3. **Track Progress**: Mark items complete as you go
4. **Explain Changes**: High-level summary at each step
5. **Document Results**: Add review section to tasks/todo.md
6. **Capture Lessons**: Update memory after corrections

## Architecture Rules

- `MiryamCore` has zero dependencies — never add external imports to this package
- ViewModels live in `MiryamFeatures` — Views never import `MiryamNetworking` or `MiryamPersistence`
- All protocols are `Sendable` — defined in `MiryamCore`, implemented in data packages
- ViewModels are `@Observable @MainActor final class` — no exceptions
- Router is `@Observable @MainActor` — injected via `.environment(router)` everywhere
- Use `@Observable` not `@ObservableObject` — Swift 6 pattern only

## Code Rules

- Swift 6 strict concurrency: `SWIFT_STRICT_CONCURRENCY = complete` — zero warnings allowed
- No stringly-typed resources: use `Color(.tokenName)`, `Image(.assetName)`, `Text(.localizedKey)`
- No hardcoded strings in Views: all user-facing text goes through String Catalogs (.xcstrings)
- Conventional commits only: `feat(scope):`, `fix(scope):`, `test(scope):`, `chore(scope):`, `docs:`
- TDD: write failing test first, then implementation
- Every screen gets snapshot tests: dark + light + accessibility tree

## Figma Integration

Before implementing ANY screen:
1. Call `get_design_context(fileKey: "L8KZBiSulfv2IEzPUQyeuq", nodeId: "<node>")` to get exact specs
2. Call `get_screenshot(fileKey: "L8KZBiSulfv2IEzPUQyeuq", nodeId: "<node>")` for visual reference
3. Download and commit any asset URLs immediately (they expire in 7 days)
4. Implement to pixel-perfect fidelity

Known Figma node IDs:
- Splash: `10985:10111`
- Songs/Home: `10985:10126`
- More Options sheet: `10985:10113`
- PlayerView, AlbumView: fetch during Wave 2

## Security Rules

- NEVER set local environment variables — use `gh secret set` for all secrets
- NEVER commit `.env` files, `.p8` files, `.p12` files, or certificates
- NEVER hardcode Apple Team ID, Apple ID, or any credential in source files
- Read all secrets from `ENV["SECRET_NAME"]` in Fastfile only
- Treat every file as potentially public

## Priority Order (if blocked)
1. App running on all platforms
2. Tests passing
3. CI/CD pipeline

If CI/CD blocks for 2+ iterations, log `TODO(ci):` and continue with app/test work.
