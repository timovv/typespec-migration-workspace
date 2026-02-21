# Common TypeSpec Client Customization Decorators

Quick reference for the most frequently used decorators in `client.tsp`.

Import:
```typespec
import "@azure-tools/typespec-client-generator-core";
using Azure.ClientGenerator.Core;
```

## Naming

### `@clientName(name, language?)`
Rename a type, property, or operation for a specific language client.
```typespec
@@clientName(MyService.InternalTableEntity, "TableEntity");
@@clientName(MyService.Models.prop1, "propertyOne", "javascript");
```

## Visibility & Access

### `@access(setting)`
Control whether a type/operation is public or internal.
```typespec
@@access(MyService.internalHelperOp, Access.internal);
@@access(MyService.InternalModel, Access.internal);
```

### `@usage(flags)`
Control where a model is used (input, output, or both).
```typespec
@@usage(MyService.RequestBody, Usage.input);
@@usage(MyService.ResponseBody, Usage.output);
```

## API Style

### `@convenientAPI(value)`
Control whether a convenient API is generated for an operation.
```typespec
@@convenientAPI(MyService.listItems, true);
```

### `@protocolAPI(value)`
Control whether a protocol (low-level) API is generated.
```typespec
@@protocolAPI(MyService.rawOp, false);
```

## Structure

### `@flattenProperty`
Flatten a nested property into its parent.
```typespec
@@flattenProperty(MyService.CreateParams.options);
```

### `@operationGroup`
Group operations under a named sub-client.
```typespec
@@operationGroup(MyService.TableOperations);
```

### `@exclude`
Exclude a type or operation from client generation.
```typespec
@@exclude(MyService.DeprecatedOp);
```

## Override

### `@override`
Override an operation's client signature.
```typespec
@@override(MyService.complexOp, MyCustomSignature);
```

## Full Reference
https://azure.github.io/typespec-azure/docs/libraries/typespec-client-generator-core/reference/decorators/
