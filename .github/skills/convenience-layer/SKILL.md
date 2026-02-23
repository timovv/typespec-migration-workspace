---
name: convenience-layer
description: Fix the SDK convenience layer to compile and pass all tests after TypeSpec regeneration. Track workarounds in WORKAROUNDS.md with root-cause analysis. Use for Phase 4 of a TypeSpec migration.
---

# Convenience Layer Patching (Phase 4)

## Overview
Fix non-generated SDK code (the convenience layer) so the package compiles and all tests pass with the new generated code.

## Context
Read `config.env` for paths. Work in the SDK package directory within `azure-sdk-for-js`.

## Prerequisites
- Phase 3 complete (TypeSpec customizations applied, SDK regenerated)
- Old generated code in `.generated-backup/` for reference

## Key Constraints
- **No unexpected API breaking changes** in review output
- Changes from `@azure/core-client` → `@azure-rest/core-client` are expected; the `@azure/core-client` dependency should be removed
- **Track ALL workarounds** in `WORKAROUNDS.md` with root cause (emitter or Core)

## Steps

### 1. Build and Categorize Errors
```bash
scripts/build-sdk.sh 2>&1 | head -100
```

Common error categories:
- **Import changes**: Generated code has different exports
- **Type mismatches**: Types differ from what convenience layer expects
- **Missing functionality**: Generated code doesn't provide something needed
- **API surface changes**: Detected by `api-extractor`

### 2. Fix Compilation Errors
Work through errors systematically:
1. Update imports to match new generated code structure
2. Adapt to type changes in the convenience layer
3. For missing functionality — add a workaround AND document it

**IMPORTANT**: Do a full migration of the convenience layer to use the new generated types and APIs directly. Do NOT create compatibility shims, adapter layers, or wrapper classes that re-expose the old AutoRest-generated interface. The convenience layer code (e.g., `TableClient.ts`, `TableServiceClient.ts`, serialization helpers) must be updated to import from and call the new TypeSpec-generated code directly. Old generated types (response headers, mappers, operation interfaces) that no longer exist should be replaced with the new equivalents or defined inline where needed.

### 3. Check API Review
The build produces `*.api.md` review files. Compare against the previous version:
```bash
find "${SDK_PACKAGE_FULL_PATH}" -name "*.api.md" -path "*/review/*"
```
Only `core-client` → `core-rest-client` migration changes are acceptable.

### 4. Run Recorded Tests
```bash
scripts/test-sdk.sh recorded
```
Fix failures: import changes, mock/recording mismatches, type assertions, missing convenience methods.

### 5. Run Live Tests
```bash
# Deploy test resources first if needed
# See azure-sdk-for-js/eng/common/TestResources/New-TestResources.ps1
scripts/test-sdk.sh live
```
Ignore 403/auth errors — those aren't related to your changes.

### 6. Document Workarounds
For EVERY workaround, add to `WORKAROUNDS.md`:
```markdown
### [Description]
- **Where**: [file path]
- **Root cause**: emitter | core
- **Description**: [what's wrong]
- **Workaround**: [what you did]
- **Suggested fix**: [how to properly fix in emitter/Core]
- **Status**: open
```

## Completion Criteria
- SDK compiles without errors
- `api-extractor` shows no unexpected API differences
- All recorded tests pass
- All live tests pass (auth failures excluded)
- All workarounds in `WORKAROUNDS.md` with root cause as emitter or Core
