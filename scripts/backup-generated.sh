#!/usr/bin/env bash
# Back up current generated code for later comparison.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../config.env"

if [ ! -d "$GENERATED_FULL_PATH" ]; then
  echo "Error: Generated code not found at ${GENERATED_FULL_PATH}"
  exit 1
fi

mkdir -p "$BACKUP_DIR"

# Remove old backup if it exists
if [ -d "${BACKUP_DIR}/generated" ]; then
  echo "Removing previous backup..."
  rm -rf "${BACKUP_DIR}/generated"
fi

echo "Backing up generated code..."
echo "  From: ${GENERATED_FULL_PATH}"
echo "  To:   ${BACKUP_DIR}/generated"
cp -r "$GENERATED_FULL_PATH" "${BACKUP_DIR}/generated"

echo "✓ Backup complete. Use scripts/compare-generated.sh to diff."
