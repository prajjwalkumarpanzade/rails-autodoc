# Serializer Support

`rails-autodoc` detects serializer gems at runtime and uses them for response schemas.

## Supported adapters

| Gem | Detection | Schema source |
|-----|-----------|---------------|
| Alba | `defined?(Alba)` | declared attributes |
| Blueprinter | `defined?(Blueprinter)` | `fields` hash |
| ActiveModel::Serializer | `defined?(ActiveModel::Serializer)` | `_attributes` |

Adapters are optional soft dependencies. If no serializer gem is present, responses fall back to model schemas or generic objects.

## Adding a custom adapter

See [CONTRIBUTING.md](../CONTRIBUTING.md#adding-a-serializer-adapter).

Each adapter implements:

- `#detect?`
- `#attributes_for(serializer_class)`
- `#schema_for(serializer_class)`

Register new adapters in `RailsAutodoc::Serializers::Registry`.
