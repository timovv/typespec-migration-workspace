#!/usr/bin/env bash
# Generate the SDK using tsp-client with local emitter and local spec repo.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../config.env"

echo "Generating SDK for ${SDK_PACKAGE_NAME}"
echo "  Spec:    ${SPEC_FULL_PATH}"
echo "  Emitter: ${EMITTER_FULL_PATH}"
echo "  Output:  ${SDK_PACKAGE_FULL_PATH}"

cd "$SDK_PACKAGE_FULL_PATH"

# Run tsp-client update with local emitter and local spec repo
npx tsp-client update \
  --local-spec-repo "$SPECS_REPO_DIR" \
  --emitter-package "${EMITTER_FULL_PATH}" \
  "$@"

echo "✓ SDK generated successfully"
echo "Run scripts/compare-generated.sh to see what changed"
