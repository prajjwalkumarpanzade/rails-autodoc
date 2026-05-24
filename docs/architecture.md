# Architecture

## Pipeline

1. `RouteInspector` discovers operations from Rails routes
2. `StrongParamsParser` extracts request schemas from controller AST
3. `SchemaMapper` maps ActiveRecord columns to OpenAPI types
4. `ResponseInferencer` inspects render/head calls
5. Serializer adapters enrich response schemas
6. `Registry` merges `swagger_doc` overrides
7. `OpenapiSpecBuilder` assembles OpenAPI 3.0.3 output
8. `Generator` writes YAML or serves JSON via the engine

## Key classes

| Class | Responsibility |
|-------|------------------|
| `RailsAutodoc::RouteInspector` | Route discovery |
| `RailsAutodoc::StrongParamsParser` | AST permit extraction |
| `RailsAutodoc::SchemaMapper` | DB schema mapping |
| `RailsAutodoc::ResponseInferencer` | Response inference |
| `RailsAutodoc::OpenapiSpecBuilder` | OpenAPI assembly |
| `RailsAutodoc::Generator` | Orchestration and export |
| `RailsAutodoc::Engine` | Swagger UI and live spec |

## Extension points

- Serializer adapters under `lib/rails_autodoc/serializers/`
- Annotation DSL via `swagger_doc`
- Configuration in `RailsAutodoc.configure`

## Testing strategy

- Combustion dummy Rails app in `spec/dummy/`
- Unit specs per component
- Appraisal matrix for Rails 5.2 through 8.0
- Golden OpenAPI fixtures for regression testing
