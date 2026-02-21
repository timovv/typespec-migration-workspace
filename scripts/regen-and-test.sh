#!/usr/bin/env bash
# Full cycle: build emitter → generate SDK → build SDK → run recorded tests.
# Use this after making emitter changes for fast iteration.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== Full regeneration cycle ==="
echo ""

echo "Step 1/4: Building emitter..."
"${SCRIPT_DIR}/build-emitter.sh"
echo ""

echo "Step 2/4: Generating SDK..."
"${SCRIPT_DIR}/generate-sdk.sh"
echo ""

echo "Step 3/4: Building SDK..."
"${SCRIPT_DIR}/build-sdk.sh"
echo ""

echo "Step 4/4: Running recorded tests..."
"${SCRIPT_DIR}/test-sdk.sh" recorded
echo ""

echo "=== ✓ Full cycle completed ==="
