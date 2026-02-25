---
name: typespec-customization
description: Apply TypeSpec client customization decorators in client.tsp to minimize API differences between old and new generated SDK code. Use for Phase 2 — iteratively customizing TypeSpec and regenerating until the generated output closely matches the original.
---

# TypeSpec Customization (Phase 2)

## Overview
Use TypeSpec decorators in `client.tsp` to make the generated SDK match the old code as closely as possible, reducing manual patching needed in Phase 4.

## Context
Read `config.env` for paths. You'll edit TypeSpec in the specs repo and regenerate in the SDK repo.

## Prerequisites
- Phase 1 complete (SDK generated, old code backed up)
- Diff available via `scripts/compare-generated.sh`

## Reference
TypeSpec client customization decorators are at:
https://azure.github.io/typespec-azure/docs/libraries/typespec-client-generator-core/reference/decorators/

See [references/common-decorators.md](references/common-decorators.md) for the most frequently used decorators.

## Steps

### 1. Analyze the Diff
Run `scripts/compare-generated.sh` and categorize differences:

| Category | Example | Fix with |
|----------|---------|----------|
| Renamed types/props | `InternalItem` → `Item` | `@clientName` |
| Missing operations | Op not generated | Check TypeSpec routes |
| Extra/missing properties | Field differences | Model adjustments |
| Different type shapes | Union vs enum | TypeSpec model changes |
| Visibility differences | Internal vs public | `@access` |
| Flattening differences | Nested vs flat params | `@flattenProperty` |

### 2. Edit client.tsp
Apply decorators in `client.tsp`. Work through categories, prioritizing:
1. Missing or extra operations (structural correctness)
2. Type/property renames (API compatibility)
3. Visibility and access modifiers
4. Flattening and shape changes

Example `client.tsp` patterns:
```typespec
import "./routes.tsp";
import "@azure-tools/typespec-client-generator-core";

using Azure.ClientGenerator.Core;

@@clientName(MyService.InternalName, "PublicName");
@@access(MyService.helperOp, Access.internal);
@@flattenProperty(MyService.CreateParams.options);
```

### 3. Regenerate and Compare
After each batch of changes:
```bash
scripts/generate-sdk.sh
scripts/compare-generated.sh
scripts/build-sdk.sh  # optional — to see if it compiles
```

### 4. Iterate
Repeat steps 2–3 until the diff is as small as possible. Document remaining differences that can't be fixed via decorators — those go to Phase 4.

## Completion Criteria
- `client.tsp` has all reasonable customizations applied
- Remaining diff documented (what can't be fixed via decorators)
- SDK regenerates cleanly with customizations
