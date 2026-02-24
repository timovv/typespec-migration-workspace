---
name: convenience-layer
description: Fix the SDK convenience layer to compile and pass all tests after TypeSpec regeneration. Track workarounds in WORKAROUNDS.md with root-cause analysis. Use for Phase 3 of a TypeSpec SDK regeneration.
---

# Convenience Layer Patching (Phase 3)

## Overview
Fix non-generated SDK code (the convenience layer) so the package compiles and all tests pass with the new generated code.

## Context
Read `config.env` for paths. Work in the SDK package directory within `azure-sdk-for-js`.

## Prerequisites
- Phase 2 complete (TypeSpec customizations applied, SDK regenerated)
- Old generated code in `.generated-backup/` for reference

## Key Constraints
- **No unexpected API breaking changes** in review output
- Changes from `@azure/core-client` → `@azure-rest/core-client` are expected; the `@azure/core-client` dependency must be **removed** from the package
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
Live tests require Azure test resources. Use the PowerShell scripts in `azure-sdk-for-js` to deploy them. **Azure PowerShell must be installed and you must already be logged in** (`Connect-AzAccount`). Test resources can be reused across multiple test runs — you only need to deploy once, then clean up when completely done.

```bash
# Deploy test resources once (from the SDK repo root)
pwsh ${SDK_REPO_DIR}/eng/common/TestResources/New-TestResources.ps1 <ServiceDirectory>

# Run live tests (can repeat as needed without redeploying)
scripts/test-sdk.sh live

# Clean up test resources when all testing is finished
pwsh ${SDK_REPO_DIR}/eng/common/TestResources/Remove-TestResources.ps1 <ServiceDirectory>
```
All live tests must pass.

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
- `api-extractor` shows no unexpected API differences — the review `.api.md` should be essentially unchanged
- All recorded tests pass (pre-existing baseline failures excluded)
- All live tests pass (pre-existing baseline failures excluded)
- All workarounds in `WORKAROUNDS.md` with root cause as emitter or Core
