#!/usr/bin/env bash
# Run SDK tests. Usage: test-sdk.sh [recorded|live]
# Uses the azure-sdk-for-js test framework (vitest + test proxy).
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../config.env"

MODE="${1:-recorded}"
cd "$SDK_PACKAGE_FULL_PATH"

case "$MODE" in
  recorded)
    echo "Running recorded (playback) tests for ${SDK_PACKAGE_NAME}..."
    npm run test:node
    ;;
  live)
    echo "Running live tests for ${SDK_PACKAGE_NAME}..."
    TEST_MODE=live npm run test:node
    ;;
  *)
    echo "Usage: test-sdk.sh [recorded|live]"
    exit 1
    ;;
esac

echo "✓ Tests completed (mode: ${MODE})"
