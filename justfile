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
	@echo "→ Installing git hooks..."
	just install-hooks
	@echo "→ Opening Xcode..."
	open Miryam.xcodeproj
	@echo ""
	@echo "✅ Bootstrap complete! Miryam is ready to build."
	@echo "   Run 'just test' to run all test lanes."
	@echo "   Run 'just lint' to check code style."

# Regenerate .xcodeproj and open workspace
open:
	mint run xcodegen generate
	open Miryam.xcodeproj

# ── Development ────────────────────────────────────────────────────────────────

# Run every test lane in order
test:
	just test-unit
	just test-snapshots
	just test-a11y
	just test-ui-smoke

# Run app + package unit tests
test-unit:
	xcodebuild test \
		-project Miryam.xcodeproj \
		-scheme MiryamAppUnitTests \
		-destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' \
		| mint run xcbeautify
	xcodebuild test \
		-project Miryam.xcodeproj \
		-scheme MiryamCore \
		-destination 'platform=macOS' \
		| mint run xcbeautify
	xcodebuild test \
		-project Miryam.xcodeproj \
		-scheme MiryamNetworking \
		-destination 'platform=macOS' \
		| mint run xcbeautify
	xcodebuild test \
		-project Miryam.xcodeproj \
		-scheme MiryamPersistence \
		-destination 'platform=macOS' \
		| mint run xcbeautify
	xcodebuild test \
		-project Miryam.xcodeproj \
		-scheme MiryamPlayer \
		-destination 'platform=macOS' \
		| mint run xcbeautify
	xcodebuild test \
		-project Miryam.xcodeproj \
		-scheme MiryamFeatures \
		-destination 'platform=macOS' \
		| mint run xcbeautify

# Run iOS + tvOS snapshot suites
test-snapshots:
	xcodebuild test \
		-project Miryam.xcodeproj \
		-scheme MiryamSnapshotTests \
		-destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' \
		| mint run xcbeautify
	xcodebuild test \
		-project Miryam.xcodeproj \
		-scheme MiryamTVSnapshotTests \
		-destination 'platform=tvOS Simulator,name=Apple TV 4K (3rd generation)' \
		| mint run xcbeautify

# Run runtime accessibility audits
test-a11y:
	xcodebuild test \
		-project Miryam.xcodeproj \
		-scheme MiryamAccessibilityXCUITests \
		-destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' \
		| mint run xcbeautify

# Run minimal end-to-end XCUITest coverage
test-ui-smoke:
	xcodebuild test \
		-project Miryam.xcodeproj \
		-scheme MiryamSmokeXCUITests \
		-destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' \
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
	SNAPSHOT_RECORD=all xcodebuild test \
		-project Miryam.xcodeproj \
		-scheme MiryamSnapshotTests \
		-destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' \
		| mint run xcbeautify
	SNAPSHOT_RECORD=all xcodebuild test \
		-project Miryam.xcodeproj \
		-scheme MiryamTVSnapshotTests \
		-destination 'platform=tvOS Simulator,name=Apple TV 4K (3rd generation)' \
		| mint run xcbeautify

# ── Security ───────────────────────────────────────────────────────────────────

# Scan repo for secrets
scan-secrets:
	gitleaks detect --source . --verbose

# Install git hooks (pre-commit secret scan)
install-hooks:
	@echo "→ Installing pre-commit hook..."
	@echo '#!/usr/bin/env bash' > .git/hooks/pre-commit
	@echo 'gitleaks git --pre-commit --staged --verbose' >> .git/hooks/pre-commit
	@chmod +x .git/hooks/pre-commit
	@echo "✅ Pre-commit hook installed."

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
	command -v rbenv   &> /dev/null || _need_install+=(rbenv)
	command -v mint    &> /dev/null || _need_install+=(mint)
	command -v gitleaks &> /dev/null || _need_install+=(gitleaks)

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
