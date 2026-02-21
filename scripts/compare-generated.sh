#!/usr/bin/env bash
# Compare backed-up generated code with current generated code.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../config.env"

BACKUP="${BACKUP_DIR}/generated"
CURRENT="$GENERATED_FULL_PATH"

if [ ! -d "$BACKUP" ]; then
  echo "Error: No backup found at ${BACKUP}"
  echo "Run scripts/backup-generated.sh first."
  exit 1
fi

if [ ! -d "$CURRENT" ]; then
  echo "Error: No generated code found at ${CURRENT}"
  exit 1
fi

echo "Comparing generated code:"
echo "  Old (backup): ${BACKUP}"
echo "  New (current): ${CURRENT}"
echo ""

# Show summary first
diff -rq "$BACKUP" "$CURRENT" 2>/dev/null || true
echo ""
echo "--- Detailed diff ---"
diff -ru "$BACKUP" "$CURRENT" 2>/dev/null || true
