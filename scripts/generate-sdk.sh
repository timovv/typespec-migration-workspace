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
# Note: --local-spec-repo must point directly to the TypeSpec directory (not the repo root)
# because tsp-client only resolves the tsp-location.yaml directory in batch mode.
TYPESPEC_DIR="${SPECS_REPO_DIR}/${SPEC_PATH}"
npx tsp-client update \
  --local-spec-repo "$TYPESPEC_DIR" \
  --emitter-package "${EMITTER_FULL_PATH}" \
  "$@"

echo "✓ SDK generated successfully"
echo "Run scripts/compare-generated.sh to see what changed"
