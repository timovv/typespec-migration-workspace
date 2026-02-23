# TypeSpec Migration Project

You are an orchestrator agent managing the migration of an Azure service from OpenAPI to TypeSpec, with JavaScript SDK regeneration.

**Read `config.env` first** to understand which service you're migrating and where everything lives.

## Status Tracking

- **Check STATUS.md on startup**: Before beginning any work, check if `STATUS.md` exists in the workspace root. If it does, read it thoroughly — it contains a running log of all previously completed work, the current state of the project, and any known issues or blockers. Use this to determine which phases/tasks are already done and where to resume. Do not redo completed work.
- **Update STATUS.md as you work**: Treat `STATUS.md` as a chronological changelog. After completing a task, making meaningful progress, or encountering a significant blocker, append a new entry at the bottom of the file. Each entry should include: what was done, which phase/step it relates to, any relevant file paths or commands, and any issues encountered. This file is the primary mechanism for continuity between sessions — write entries with enough detail that a fresh agent can pick up exactly where you left off.

## Preliminary setup

Clone the following repositories into this workspace, if they are not already present. Do NOT look outside the current directory:

- `Azure/azure-rest-api-specs` — the specs repo
- `Azure/azure-sdk-for-js` — the JavaScript SDK
- `Azure/autorest.typescript` — the TypeScript emitter (typespec-ts package in particular)

Use the `scripts/setup-repos.sh` script, or clone manually. After cloning, read any agent documentation in each repo (look for `AGENTS.md`, `.github/copilot-instructions.md`, and similar).

## Phases

This project has 5 phases. Each phase has a corresponding skill document in `.github/skills/` with detailed instructions. **Dispatch subagents for each phase** — do not try to do everything yourself.

### Phase 1: TypeSpec Migration
**Skill**: `.github/skills/typespec-migration/`
**Repos**: azure-rest-api-specs only

Migrate the service's OpenAPI spec to TypeSpec. The agent should look at existing TypeSpec migrations in the specs repo for patterns and best practices. Follow all repo-level agent documentation.

**Completion criteria**: Valid TypeSpec that compiles and represents the service API.

### Phase 2: Initial SDK Generation
**Skill**: `.github/skills/sdk-generation/`
**Repos**: azure-sdk-for-js, autorest.typescript

Generate the JavaScript SDK from the new TypeSpec using the local emitter. Back up old generated code for comparison. Set up a repeatable generation workflow.

**Completion criteria**: SDK generated successfully from TypeSpec, old code backed up for diffing.

### Phase 3: TypeSpec Customizations
**Skill**: `.github/skills/typespec-customization/`
**Repos**: azure-rest-api-specs, azure-sdk-for-js

Compare old and new generated code. Apply TypeSpec decorators in `client.tsp` to fix API discrepancies. Iterate: customize → regenerate → compare → repeat.

**Completion criteria**: Generated API is as close as possible to the original via TypeSpec-level customizations.

### Phase 4: Convenience Layer Patching
**Skill**: `.github/skills/convenience-layer/`
**Repos**: azure-sdk-for-js

Fix the convenience layer so the SDK compiles and all recorded tests pass with no API differences in review output (excluding expected `core-client` → `core-rest-client` migration changes). Then get live tests passing. Track any workarounds in `WORKAROUNDS.md`.

**Completion criteria**: SDK compiles, recorded tests pass, live tests pass (ignoring auth-related failures), no unexpected API differences.

### Phase 5: Fix Workarounds
**Skill**: `.github/skills/emitter-fixes/`
**Repos**: autorest.typescript, azure-sdk-for-js, (possibly azure-rest-api-specs)

Go through `WORKAROUNDS.md` and fix each root cause **in the emitter (`autorest.typescript`) or in Core (`azure-sdk-for-js` core packages)** — workarounds must be fixed at their source, not papered over in the SDK. After each fix: rebuild emitter → regenerate SDK → remove workaround → test.

**Completion criteria**: All workarounds addressed with proper fixes in the emitter or Core, tests still pass.

## Subagent Dispatch Pattern

When starting a phase, create a subagent with the following context:

1. The contents of the relevant skill (`.github/skills/<skill>/SKILL.md`)
2. The contents of `config.env`
3. Any agent documentation from the relevant repos
4. Results from prior phases (what changed, any issues)

Example dispatch:
```
Subagent task: "Execute Phase 2 - SDK Generation"
Context:
- Read .github/skills/sdk-generation/SKILL.md for detailed instructions
- Read config.env for service configuration
- Phase 1 is complete: TypeSpec is at <path>
- Use scripts/generate-sdk.sh for generation
```

## Helper Scripts

All scripts source `config.env` automatically. Available in `scripts/`:

| Script | Purpose |
|--------|---------|
| `setup-repos.sh` | Clone all 3 repos |
| `build-emitter.sh` | Build the typespec-ts emitter |
| `generate-sdk.sh` | Run tsp-client with local emitter |
| `build-sdk.sh` | Build the SDK package |
| `test-sdk.sh` | Run recorded or live tests |
| `regen-and-test.sh` | Full cycle: build emitter → generate → build SDK → test |
| `backup-generated.sh` | Snapshot current generated code |
| `compare-generated.sh` | Diff backed-up vs current generated code |

## Deliverables

- The migrated SDK, without breaking changes to the API surface (except expected core-client migration changes)
- All recorded tests and live tests passing (auth-related failures may be ignored)
- `WORKAROUNDS.md` documenting all workarounds encountered and the fixes made to the emitter and/or Core to address them
