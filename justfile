# Miryam — task runner
# Usage: just <recipe>
# Install: brew install just

# Default: show available commands
default:
	@just --list

# ── Setup ──────────────────────────────────────────────────────────────────────

# First-time setup: install all deps, generate project, open Xcode
bootstrap: _check-homebrew _check-rbenv
	@echo "→ Installing gems..."
	gem install bundler --quiet
	bundle install
	@echo "→ Bootstrapping Mint tools..."
	mint bootstrap
	@echo "→ Generating Xcode project..."
	mint run xcodegen generate
	@echo "→ Opening Xcode..."
	open Miryam.xcodeproj
	@echo "✅ Bootstrap complete!"

# Regenerate .xcodeproj and open workspace
open:
	mint run xcodegen generate
	open Miryam.xcodeproj

# ── Development ────────────────────────────────────────────────────────────────

# Run all tests (unit + UI)
test:
	xcodebuild test \
		-project Miryam.xcodeproj \
		-scheme Miryam \
		-destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
		-resultBundlePath TestResults.xcresult \
		| mint run xcbeautify

# Lint Swift code
lint:
	mint run swiftlint lint --strict
	mint run swiftformat --lint .

# Auto-fix formatting
format:
	mint run swiftformat .
	mint run swiftlint --fix

# Regenerate snapshot reference images
snapshot-update:
	xcodebuild test \
		-project Miryam.xcodeproj \
		-scheme MiryamTests \
		-destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
		-testArguments "-recordSnapshots YES" \
		| mint run xcbeautify

# ── CI/CD ──────────────────────────────────────────────────────────────────────

# Upload to TestFlight
beta:
	bundle exec fastlane beta

# Release to App Store
release:
	bundle exec fastlane release

# ── Internal checks ────────────────────────────────────────────────────────────

_check-homebrew:
	#!/usr/bin/env bash
	if ! command -v brew &> /dev/null; then
		echo "❌ Homebrew not found. Install from https://brew.sh"
		exit 1
	fi

_check-rbenv:
	#!/usr/bin/env bash
	if ! command -v rbenv &> /dev/null; then
		echo "❌ rbenv not found. Run: brew install rbenv"
		exit 1
	fi
	rbenv install --skip-existing
