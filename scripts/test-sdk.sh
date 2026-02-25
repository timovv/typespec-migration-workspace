#!/usr/bin/env bash
# Run SDK tests: recorded (playback) tests first, then live tests.
# Uses the azure-sdk-for-js test framework (vitest + test proxy).
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../config.env"

cd "$SDK_PACKAGE_FULL_PATH"

echo "=== Running recorded (playback) tests for ${SDK_PACKAGE_NAME}... ==="
npm run test:node

echo ""
echo "=== Running live tests for ${SDK_PACKAGE_NAME}... ==="
TEST_MODE=live npm run test:node

echo ""
echo "✓ All tests completed (recorded + live)"
