#!/usr/bin/env bash
# Build the typespec-ts emitter from the local autorest.typescript repo.
# Uses pnpm + turbo (the repo's build system). Turbo handles building
# dependencies automatically via the ^build dependency graph.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../config.env"

echo "Building emitter at: ${EMITTER_REPO_DIR}"
cd "$EMITTER_REPO_DIR"

# Install dependencies if needed
if [ ! -d "node_modules" ]; then
  echo "Installing dependencies (pnpm)..."
  PUPPETEER_SKIP_DOWNLOAD=true pnpm install
fi

# Build typespec-ts and its dependencies via turbo
echo "Building ${EMITTER_PACKAGE_NAME} (with dependencies)..."
pnpm turbo build --filter="${EMITTER_PACKAGE_NAME}..."

echo "✓ Emitter built successfully"
