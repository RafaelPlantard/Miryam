#!/bin/bash
set -euo pipefail

# Pre-commit hook for Claude Code: runs SwiftLint and SwiftFormat
# before any git commit to catch lint issues early.

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command')

# Only intercept git commit commands
if ! echo "$COMMAND" | grep -qE '^\s*git\s+commit'; then
  exit 0
fi

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
cd "$PROJECT_DIR"

ERRORS=""

echo "Running SwiftLint..." >&2
if ! mint run swiftlint lint --strict 2>&1 >&2; then
  ERRORS="${ERRORS}SwiftLint found violations. "
fi

echo "Running SwiftFormat..." >&2
if ! mint run swiftformat --lint . 2>&1 >&2; then
  ERRORS="${ERRORS}SwiftFormat found violations. Run 'mint run swiftformat .' to fix. "
fi

if [ -n "$ERRORS" ]; then
  echo "Pre-commit lint failed: ${ERRORS}" >&2
  exit 2
fi

echo "Lint checks passed." >&2
exit 0
