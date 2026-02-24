#!/usr/bin/env bash
# Clone all required repositories into the workspace.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../config.env"

clone_if_missing() {
  local repo="$1"
  local dir="$2"
  if [ -d "$dir" ]; then
    echo "✓ $dir already exists, skipping clone"
  else
    echo "Cloning $repo → $dir ..."
    git clone "https://github.com/${repo}.git" "$dir"
  fi
}

clone_if_missing "$SPECS_REPO" "$SPECS_REPO_DIR"
clone_if_missing "$SDK_REPO" "$SDK_REPO_DIR"
clone_if_missing "$EMITTER_REPO" "$EMITTER_REPO_DIR"

# Check out the spec commit if SPEC_COMMIT is set
if [ -n "${SPEC_COMMIT:-}" ] && [ -d "$SPECS_REPO_DIR" ]; then
  echo "Checking out spec commit ${SPEC_COMMIT} in ${SPECS_REPO_DIR} ..."
  git -C "$SPECS_REPO_DIR" fetch origin "$SPEC_COMMIT" 2>/dev/null || true
  git -C "$SPECS_REPO_DIR" checkout "$SPEC_COMMIT"
  echo "✓ Specs repo at ${SPEC_COMMIT}"
fi

echo ""
echo "All repositories cloned. Next steps:"
echo "  1. Read agent docs in each repo (AGENTS.md, .github/copilot-instructions.md)"
echo "  2. Build the emitter: scripts/build-emitter.sh"
