---
name: sdk-generation
description: Generate the JavaScript SDK from TypeSpec using a local emitter build via tsp-client. Use for Phase 2 of a TypeSpec migration — initial SDK generation and setting up repeatable generation workflow.
---

# SDK Generation (Phase 2)

## Overview
Generate the JavaScript SDK from TypeSpec using the local emitter, and establish a repeatable regeneration workflow for subsequent phases.

## Context
Read `config.env` for:
- `SDK_PACKAGE_FULL_PATH` — the SDK package directory
- `GENERATED_FULL_PATH` — where generated code goes (`src/generated`)
- `EMITTER_FULL_PATH` — the local emitter package
- `SPEC_FULL_PATH` — the TypeSpec source

## Prerequisites
- Phase 1 complete (TypeSpec exists and compiles)
- Emitter built (`scripts/build-emitter.sh`)

## Steps

### 1. Back Up Old Generated Code
Before anything, snapshot the current generated code for comparison:
```bash
scripts/backup-generated.sh
```
This copies `src/generated/` to `.generated-backup/`.

### 2. Configure tsp-location.yaml
The SDK package needs a `tsp-location.yaml` pointing to the TypeSpec. Check if one exists; if not, create it:

```yaml
directory: <SPEC_PATH>/<TYPESPEC_NAMESPACE>
commit: <HEAD of specs repo>
repo: Azure/azure-rest-api-specs
additionalDirectories: []
```

### 3. Generate the SDK
```bash
scripts/generate-sdk.sh
```

This script runs `tsp-client update` with the local emitter and local spec repo. If it fails:
- Is the emitter built? → `scripts/build-emitter.sh`
- Is `tsp-location.yaml` correct?
- TypeSpec compilation errors? → Go back to Phase 1

### 4. Verify Generation
- Confirm files were created in `src/generated/`
- Run `scripts/compare-generated.sh` to see the diff
- Look for obvious issues (missing operations, wrong types)

### 5. Build the SDK
```bash
scripts/build-sdk.sh
```
The build may fail at this point — that's expected. The goal is to identify what needs fixing.

## Iteration Workflow
For subsequent phases, use these scripts:
```bash
# After TypeSpec changes (Phase 3)
scripts/generate-sdk.sh && scripts/build-sdk.sh

# After emitter changes (Phase 5)
scripts/regen-and-test.sh

# To see what changed
scripts/compare-generated.sh
```

## Completion Criteria
- Old generated code backed up in `.generated-backup/`
- New code generated from TypeSpec in `src/generated/`
- Generation workflow is repeatable via scripts
- Initial diff reviewed to understand scope of changes
