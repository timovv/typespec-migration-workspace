#!/usr/bin/env bash
# Build the SDK package using the azure-sdk-for-js build system (pnpm + turbo).
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../config.env"

echo "Building ${SDK_PACKAGE_NAME}"
cd "$SDK_REPO_DIR"

# Install dependencies if needed
if [ ! -d "node_modules" ]; then
  echo "Installing dependencies (pnpm)..."
  pnpm install
fi

# Build the package and all its dependencies via turbo
echo "Building ${SDK_PACKAGE_NAME} (with dependencies)..."
pnpm turbo build --filter="${SDK_PACKAGE_NAME}..." --token 1

echo "✓ SDK built successfully"
