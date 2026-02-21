---
name: repo-setup
description: Clone and configure the three required repositories (azure-rest-api-specs, azure-sdk-for-js, autorest.typescript) for a TypeSpec migration. Use this skill at the start of any migration to bootstrap the workspace.
---

# Repository Setup

## Overview
Clone repos, install dependencies, build the emitter, and validate `config.env`.

## Steps

### 1. Clone Repositories
```bash
source config.env
scripts/setup-repos.sh
```

### 2. Read Repository Agent Documentation
After cloning, read agent-facing docs in each repo. These contain mandatory conventions:
- **azure-rest-api-specs**: Look for `AGENTS.md`, `.github/copilot-instructions.md`, or similar at repo root and within `specification/`.
- **azure-sdk-for-js**: Look for `AGENTS.md`, `.github/copilot-instructions.md`, SDK package README.
- **autorest.typescript**: Look for `AGENTS.md`, `.github/copilot-instructions.md`, `packages/typespec-ts/README.md`.

### 3. Build the Emitter
The emitter must be built before any SDK generation:
```bash
scripts/build-emitter.sh
```

### 4. Validate Configuration
Verify `config.env` values match actual repo structure:
- Confirm `SPEC_PATH` exists in specs repo
- Confirm `SDK_PACKAGE_DIR` exists in SDK repo
- Confirm `EMITTER_PACKAGE_DIR` exists in emitter repo

## Completion Criteria
- All 3 repos cloned into the workspace
- Repository agent documentation read and understood
- Emitter built successfully
- `config.env` validated against actual paths
