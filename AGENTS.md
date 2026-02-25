# TypeSpec Migration Project

You are an orchestrator agent managing the regeneration of an Azure JavaScript SDK from an existing TypeSpec definition.

**Read `config.env` first** to understand which service you're working on and where everything lives. The user provides a commit hash (and/or URL) for the `azure-rest-api-specs` repo that already contains the TypeSpec — you do **not** need to create or migrate the TypeSpec yourself.

**Do not make any git commits.** All changes should remain as uncommitted working tree modifications.

## Status Tracking

- **Check STATUS.md on startup**: Before beginning any work, check if `STATUS.md` exists in the workspace root. If it does, read it thoroughly — it contains a running log of all previously completed work, the current state of the project, and any known issues or blockers. Use this to determine which phases/tasks are already done and where to resume. Do not redo completed work.
- **Update STATUS.md as you work**: Treat `STATUS.md` as a chronological changelog. After completing a task, making meaningful progress, or encountering a significant blocker, append a new entry at the bottom of the file. Each entry should include: what was done, which phase/step it relates to, any relevant file paths or commands, and any issues encountered. This file is the primary mechanism for continuity between sessions — write entries with enough detail that a fresh agent can pick up exactly where you left off.

## Preliminary setup

Clone the following repositories into this workspace, if they are not already present. Do NOT look outside the current directory:

- `Azure/azure-rest-api-specs` — the specs repo
- `Azure/azure-sdk-for-js` — the JavaScript SDK
- `Azure/autorest.typescript` — the TypeScript emitter (typespec-ts package in particular)

Use the `scripts/setup-repos.sh` script, or clone manually. After cloning, read any agent documentation in each repo (look for `AGENTS.md`, `.github/copilot-instructions.md`, and similar).

**Important**: After cloning `azure-rest-api-specs`, check out the commit specified by `SPEC_COMMIT` in `config.env` so that the TypeSpec definition is available at `SPEC_PATH`.

## Baseline Test Run (Prerequisite)

Before starting any migration work, run **both recorded and live tests** against the existing SDK to establish a baseline. Record which tests (if any) are already failing — these pre-existing failures are allowed to remain after migration. Only regressions (tests that were passing before but fail after) count as failures.

**Both recorded AND live tests are required for the baseline.**

For **recorded tests**, no special setup is needed — they use mocked/recorded responses:

```bash
scripts/build-sdk.sh
scripts/test-sdk.sh recorded   # capture any pre-existing failures
```

For **live tests**, you must first deploy test resources to Azure. The deployment provisions the necessary Azure resources and outputs the environment variables that live tests require. Azure PowerShell must be installed and you must already be logged in (`Connect-AzAccount`).

**IMPORTANT: Do NOT skip live tests.** Check for Azure login with `pwsh -Command "Get-AzContext"`. If logged in, deploy test resources and run live tests. The live test baseline is mandatory — without it you cannot verify the migration hasn't introduced regressions. Never assume credentials are unavailable without checking first.

```powershell
# From the azure-sdk-for-js repo root, deploy test resources for the package:
eng/common/TestResources/New-TestResources.ps1 <sdk-package-dir>
```

This script finds and deploys the `test-resources.bicep` template for the service and outputs the required environment variables. You must set them in your shell session before running live tests:

```bash
scripts/test-sdk.sh live       # requires env vars from test resource deployment
```

Save the baseline results in `STATUS.md` so they can be referenced throughout the migration.

## Phases

This project has 5 phases. Each phase has a corresponding skill document in `.github/skills/` with detailed instructions. **Dispatch subagents for each phase** — do not try to do everything yourself.

### Phase 1: Initial SDK Generation
**Skill**: `.github/skills/sdk-generation/`
**Repos**: azure-sdk-for-js, autorest.typescript

Generate the JavaScript SDK from the existing TypeSpec using the local emitter. Back up old generated code for comparison. Set up a repeatable generation workflow.

**Prerequisite**: The specs repo is checked out at `SPEC_COMMIT` and the TypeSpec compiles.

**Completion criteria**: SDK generated successfully from TypeSpec, old code backed up for diffing.

### Phase 2: TypeSpec Customizations
**Skill**: `.github/skills/typespec-customization/`
**Repos**: azure-rest-api-specs, azure-sdk-for-js

Compare old and new generated code. Apply TypeSpec decorators in `client.tsp` to fix API discrepancies. Iterate: customize → regenerate → compare → repeat.

**Completion criteria**: Generated API is as close as possible to the original via TypeSpec-level customizations.

### Phase 3: Convenience Layer Patching
**Skill**: `.github/skills/convenience-layer/`
**Repos**: azure-sdk-for-js
**Recommended model**: Use a high-reasoning model (e.g. `claude-opus-4.6`) for subagents in this phase — the convenience layer migration requires deep code understanding and careful refactoring.

Fix the convenience layer so the SDK compiles and all recorded tests pass with no API differences in review output (excluding expected `core-client` → `core-rest-client` migration changes). Then get live tests passing. Track any workarounds in `WORKAROUNDS.md`.

**Completion criteria**: SDK compiles, recorded tests pass, live tests pass (pre-existing baseline failures excluded), no unexpected API differences.

### Phase 4: Fix Workarounds
**Skill**: `.github/skills/emitter-fixes/`
**Repos**: autorest.typescript, azure-sdk-for-js, (possibly azure-rest-api-specs)

Go through `WORKAROUNDS.md` and fix each root cause **in the emitter (`autorest.typescript`) or in Core (`azure-sdk-for-js` core packages)** — workarounds must be fixed at their source, not papered over in the SDK. After each fix: rebuild emitter → regenerate SDK → remove workaround → test.

**Completion criteria**: All workarounds addressed with proper fixes in the emitter or Core, tests still pass.

### Phase 5: Final Review
**Repos**: all

Run a final review subagent to verify all success criteria are met:

1. **Build**: SDK compiles without errors (`scripts/build-sdk.sh`)
2. **API review**: The `.api.md` review file is essentially unchanged from the original (no unexpected API breaks)
3. **Recorded tests**: All pass (`scripts/test-sdk.sh recorded`), excluding pre-existing baseline failures
4. **Live tests**: All pass (`scripts/test-sdk.sh live`), excluding pre-existing baseline failures
5. **Dependency check**: `@azure/core-client` is removed from `package.json`
6. **Workarounds**: `WORKAROUNDS.md` entries all have status "fixed" with proper emitter/Core fixes

If any criterion is not met, report exactly what failed and what needs to be addressed.

**Completion criteria**: All of the above verified and passing.

### Phase 6: API Surface Verification
**Repos**: azure-sdk-for-js

After all other phases pass, perform a detailed line-by-line audit of the `.api.md` diff to catch **any** breaking change. This phase exists because it is easy to miss subtle breaks (removed properties, narrowed types, changed response shapes) in a large diff.

**IMPORTANT**: This phase is mandatory. Do NOT skip it. Previous migrations missed breaking changes that were only caught by manual review.

#### Steps

1. **Generate the diff**:
   ```bash
   cd azure-sdk-for-js
   git diff -- ${SDK_PACKAGE_DIR}/review/*.api.md
   ```

2. **Classify every change** into one of these categories:

   | Category | Example | Action |
   |----------|---------|--------|
   | **Expected import change** | `@azure/core-client` → `@azure-rest/core-client` | ✅ Acceptable |
   | **Removed property** | `clientRequestId?: string` deleted from an interface | ❌ Must restore |
   | **Removed type** | `KnownSomeStatusType` enum gone | ❌ Must restore |
   | **Narrowed type** | `string` → `"a" \| "b" \| "c"` | ❌ Must restore as `string` |
   | **Changed response shape** | `SomeOperationHeaders` → `void` | ❌ Must restore original shape |
   | **Lost intersection** | `Headers & Body` → `Body` only | ❌ Must restore intersection |
   | **Added `(undocumented)`** | Missing JSDoc on a public member | ⚠️ Add JSDoc comments |
   | **`ae-forgotten-export` warning** | Type conflict between generated and local types | ❌ Must fix — define type locally |

3. **Fix every breaking change**:
   - Restore removed properties and types in `generatedModels.ts` (define them locally — do NOT depend on generated code exporting them)
   - Restore original response type shapes (composite header+body types)
   - Keep extensible union types as `string`, not a narrow literal union (e.g., if the TypeSpec defines `union Foo { string, "a", "b" }`, the public API type should remain `string`)
   - If the generated code exports a type with the same name but different shape, define the type locally to avoid api-extractor `_2` suffix conflicts
   - Add JSDoc to all public interface members to prevent `(undocumented)` markers

4. **Populate response headers in the convenience layer**:
   - Operations must extract standard HTTP headers (`x-ms-client-request-id`, `x-ms-request-id`, `x-ms-version`, `date`, `etag`, etc.) from raw responses and include them in return values
   - Use the header name mappings: `clientRequestId` ← `x-ms-client-request-id`, `requestId` ← `x-ms-request-id`, `version` ← `x-ms-version`, `date` ← `date`, `etag` ← `etag`

5. **Rebuild and re-diff** until the only remaining changes are expected import changes (`CommonClientOptions` → `ClientOptions`, `coreClient.OperationOptions` → `OperationOptions`)

6. **Run both recorded AND live tests** to confirm nothing broke

**Completion criteria**: The `.api.md` diff contains ONLY expected `core-client` → `core-rest-client` import changes. Zero removed properties, zero removed types, zero narrowed types, zero changed response shapes.

## Subagent Dispatch Pattern

When starting a phase, create a subagent with the following context:

1. The contents of the relevant skill (`.github/skills/<skill>/SKILL.md`)
2. The contents of `config.env`
3. Any agent documentation from the relevant repos
4. Results from prior phases (what changed, any issues)

Example dispatch:
```
Subagent task: "Execute Phase 1 - SDK Generation"
Context:
- Read .github/skills/sdk-generation/SKILL.md for detailed instructions
- Read config.env for service configuration
- Specs repo checked out at SPEC_COMMIT, TypeSpec is at SPEC_PATH
- Use scripts/generate-sdk.sh for generation
```

## Helper Scripts

All scripts source `config.env` automatically. Available in `scripts/`:

| Script | Purpose |
|--------|---------|
| `setup-repos.sh` | Clone all 3 repos and check out spec commit |
| `build-emitter.sh` | Build the typespec-ts emitter |
| `generate-sdk.sh` | Run tsp-client with local emitter |
| `build-sdk.sh` | Build the SDK package |
| `test-sdk.sh` | Run recorded or live tests |
| `regen-and-test.sh` | Full cycle: build emitter → generate → build SDK → test |
| `backup-generated.sh` | Snapshot current generated code |
| `compare-generated.sh` | Diff backed-up vs current generated code |

## Deliverables

- The migrated SDK, with **no API breaking changes** — the review `.api.md` file should be essentially unchanged (except expected `core-client` → `core-rest-client` migration changes); the `@azure/core-client` dependency must be **removed** from the package
- All recorded tests and live tests passing (tests that were already failing in the pre-migration baseline are allowed to remain failing)
- `WORKAROUNDS.md` documenting all workarounds encountered and the fixes made to the emitter and/or Core to address them
