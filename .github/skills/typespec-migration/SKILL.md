---
name: typespec-migration
description: Migrate an Azure service from OpenAPI/Swagger to TypeSpec in the azure-rest-api-specs repo. Use when performing Phase 1 of a TypeSpec migration — creating the TypeSpec definition for a service.
---

# TypeSpec Migration (Phase 1)

## Overview
Migrate a service's OpenAPI spec to TypeSpec. This works solely in the `azure-rest-api-specs` repo.

## Context
Read `config.env` for:
- `SPEC_PATH` — location of the service spec
- `TYPESPEC_NAMESPACE` — the TypeSpec namespace (e.g. `Azure.Data.Tables`)
- `SPECS_REPO_DIR` — path to the specs repo

## Steps

### 1. Study Existing TypeSpec Migrations
Browse `specification/` in the specs repo for services that already have TypeSpec (`.tsp` files). Look at **multiple examples** to understand:
- Directory layout (`main.tsp`, `models.tsp`, `routes.tsp`, `client.tsp`, `tspconfig.yaml`)
- How OpenAPI operations map to TypeSpec operations
- Naming conventions and decorator usage
- How versioning is handled
- Common patterns: pagination, long-running operations, error models

### 2. Understand the Existing OpenAPI Spec
Read the existing Swagger/OpenAPI files in `${SPEC_PATH}`:
- Inventory all operations, models, and enums
- Note custom headers, query parameters, response patterns
- Identify API versions

### 3. Follow Repo Agent Documentation
**Critical**: Follow any agent documentation found in the specs repo (`AGENTS.md`, `.github/copilot-instructions.md`, etc.). These define mandatory conventions for TypeSpec structure, linting, and review.

### 4. Create the TypeSpec
Create TypeSpec files. Typical structure:
```
${SPEC_PATH}/${TYPESPEC_NAMESPACE}/
├── main.tsp          # Entry point, imports, service declaration
├── models.tsp        # Data models and enums
├── routes.tsp        # API operations
├── client.tsp        # Client customizations (initially minimal)
├── tspconfig.yaml    # Compiler + emitter configuration
```

Key considerations:
- Use the namespace from `config.env`
- Map all OpenAPI operations faithfully
- Use `@doc` decorators for documentation
- Use appropriate Azure-specific decorators (`@azure-tools/typespec-azure-core`, etc.)
- Model all status codes and error responses

### 5. Configure tspconfig.yaml
Ensure `tspconfig.yaml` includes the JavaScript emitter configuration. See [references/tspconfig-example.yaml](references/tspconfig-example.yaml) for a starting point.

### 6. Compile and Validate
```bash
cd "${SPECS_REPO_DIR}/${SPEC_PATH}/${TYPESPEC_NAMESPACE}"
npx tsp compile .
```
Fix all compilation errors. Run any linters documented in the specs repo.

## Completion Criteria
- TypeSpec compiles without errors
- All operations from the OpenAPI spec are represented
- Follows repo conventions from agent documentation
- `tspconfig.yaml` configured for JavaScript emitter
