#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -eq 0 ]; then
  echo "Usage: $0 <tool> [tool...]"
  exit 1
fi

if ! command -v brew >/dev/null 2>&1; then
  echo "::error::Homebrew is required on self-hosted runners. Install it from https://brew.sh before running this workflow."
  exit 1
fi

command_name_for() {
  case "$1" in
    mint) echo "mint" ;;
    xcresultparser) echo "xcresultparser" ;;
    gnupg) echo "gpg" ;;
    gh) echo "gh" ;;
    rbenv) echo "rbenv" ;;
    *)
      echo "::error::Unsupported tool '$1'."
      exit 1
      ;;
  esac
}

brew_formula_for() {
  case "$1" in
    mint) echo "mint" ;;
    xcresultparser) echo "xcresultparser" ;;
    gnupg) echo "gnupg" ;;
    gh) echo "gh" ;;
    rbenv) echo "rbenv" ;;
    *)
      echo "::error::Unsupported tool '$1'."
      exit 1
      ;;
  esac
}

for tool in "$@"; do
  command_name=$(command_name_for "$tool")
  if command -v "$command_name" >/dev/null 2>&1; then
    echo "✓ ${tool} already installed"
    continue
  fi

  formula=$(brew_formula_for "$tool")
  echo "→ Installing ${tool} via Homebrew (${formula})..."
  brew install "$formula"
done
