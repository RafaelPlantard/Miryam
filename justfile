# Miryam — task runner
# Usage: just <recipe>
# Install: brew install just

# Default: show available commands
default:
	@just --list

# ── Setup ──────────────────────────────────────────────────────────────────────

# First-time setup: install all deps, generate project, open Xcode
bootstrap: _ensure-deps
	@echo "→ Installing Ruby gems..."
	gem install bundler --quiet
	bundle install --quiet
	@echo "→ Bootstrapping Mint tools (XcodeGen, SwiftLint, SwiftFormat, xcbeautify)..."
	mint bootstrap
	@echo "→ Generating Xcode project..."
	mint run xcodegen generate
	@echo "→ Opening Xcode..."
	open Miryam.xcodeproj
	@echo ""
	@echo "✅ Bootstrap complete! Miryam is ready to build."
	@echo "   Run 'just test' to run all tests."
	@echo "   Run 'just lint' to check code style."

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

# ── Internal: auto-install dependencies ────────────────────────────────────────

_ensure-deps:
	#!/usr/bin/env bash
	set -euo pipefail

	_need_install=()

	# ── Homebrew (hard requirement) ──
	if ! command -v brew &> /dev/null; then
		echo "❌ Homebrew is required. Install from https://brew.sh"
		exit 1
	fi

	# ── Detect missing tools ──
	command -v rbenv  &> /dev/null || _need_install+=(rbenv)
	command -v mint   &> /dev/null || _need_install+=(mint)

	if [ ${#_need_install[@]} -gt 0 ]; then
		echo "📦 Missing tools: ${_need_install[*]}"
		read -r -p "   Install via Homebrew? [Y/n] " _answer
		_answer=${_answer:-Y}
		if [[ "$_answer" =~ ^[Yy]$ ]]; then
			for tool in "${_need_install[@]}"; do
				echo "   → brew install $tool"
				brew install "$tool"
			done
		else
			echo "❌ Cannot continue without: ${_need_install[*]}"
			exit 1
		fi
	fi

	# ── rbenv: ensure correct Ruby version is installed ──
	if command -v rbenv &> /dev/null; then
		eval "$(rbenv init - 2>/dev/null || true)"
		REQUIRED_RUBY=$(cat .ruby-version)
		if ! rbenv versions --bare | grep -q "^${REQUIRED_RUBY}$"; then
			echo "📦 Ruby $REQUIRED_RUBY not found."
			read -r -p "   Install via rbenv? [Y/n] " _answer
			_answer=${_answer:-Y}
			if [[ "$_answer" =~ ^[Yy]$ ]]; then
				echo "   → rbenv install $REQUIRED_RUBY (this may take a few minutes)"
				rbenv install "$REQUIRED_RUBY"
			else
				echo "❌ Cannot continue without Ruby $REQUIRED_RUBY"
				exit 1
			fi
		fi
	fi

	echo "✅ All dependencies available."
