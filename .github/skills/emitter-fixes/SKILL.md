---
name: emitter-fixes
description: Fix root causes of SDK workarounds by making changes to the TypeScript emitter (autorest.typescript) and/or Core packages (azure-sdk-for-js). Use for Phase 5 — eliminating workarounds with proper fixes at the source.
---

# Emitter & Core Fixes (Phase 5)

## Overview
Fix the root cause of every workaround in `WORKAROUNDS.md` by making changes to the **emitter** (`autorest.typescript`) and/or **Core** packages (`azure-sdk-for-js`). Workarounds must be fixed at their source — not left as hacks in the SDK.

## Context
Read `config.env` for paths. You'll work across all three repos.

## Prerequisites
- Phase 4 complete (SDK compiling, tests passing with workarounds)
- `WORKAROUNDS.md` populated with root causes and suggested fixes

## Steps

### 1. Triage Workarounds
Read `WORKAROUNDS.md` and group by root cause:

| Root Cause | Repo | Fix Location |
|-----------|------|-------------|
| emitter | autorest.typescript | `packages/typespec-ts/src/` |
| core | azure-sdk-for-js | `sdk/core/` packages |

### 2. Fix Emitter Issues
For each emitter workaround:

1. **Understand**: What does the emitter generate incorrectly?
2. **Locate**: Find the relevant generation logic in `packages/typespec-ts/src/`
3. **Fix**: Edit the emitter source
4. **Rebuild emitter**: `scripts/build-emitter.sh`
5. **Regenerate SDK**: `scripts/generate-sdk.sh`
6. **Remove workaround** from the convenience layer
7. **Build and test**: `scripts/build-sdk.sh && scripts/test-sdk.sh recorded`

Or use the full cycle:
```bash
scripts/regen-and-test.sh
```

### 3. Fix Core Issues
For each core workaround:

1. **Locate** the relevant core package in `azure-sdk-for-js/sdk/core/`
2. **Make the fix**
3. **Build** the core package
4. **Remove workaround** from the convenience layer
5. **Build and test**: `scripts/build-sdk.sh && scripts/test-sdk.sh recorded`

### 4. Validate Everything
After all workarounds are fixed:
```bash
scripts/regen-and-test.sh    # full cycle
scripts/test-sdk.sh live     # live tests
```

### 5. Update WORKAROUNDS.md
Mark each workaround as fixed:
```markdown
- **Status**: fixed
- **Fix**: [description of fix, file changed, repo]
```

## Fast Iteration Loop (Emitter Fixes)
```bash
# 1. Edit emitter source in autorest.typescript/packages/typespec-ts/src/
# 2. Full cycle:
scripts/regen-and-test.sh
# 3. If tests fail, go to step 1
```

## Completion Criteria
- All workarounds in `WORKAROUNDS.md` have status "fixed"
- Fixes are in the emitter or Core — NOT in the SDK convenience layer
- SDK compiles, all recorded tests pass, all live tests pass
- `WORKAROUNDS.md` documents each fix location
