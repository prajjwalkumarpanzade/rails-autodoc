# FAQ

## Why not use FastAPI-style type-driven docs?

Rails APIs rarely declare request/response contracts in types. `rails-autodoc` meets teams where they are: strong params and routes.

## Will docs drift?

Static exports can drift if you forget to regenerate. Use `rake autodoc:verify` in CI to catch drift.

## How accurate are generated schemas?

Good for endpoint discovery, request field names, and common REST patterns. Validation rules, enums, and complex response shapes need DSL overrides or serializer gems.

## Does it work on legacy Rails 5 apps?

Yes. The gem targets Rails 5.2 through 8.x and uses CDN-based Swagger UI to avoid asset pipeline dependencies.

## Can I hide internal routes?

Yes. Use `config.exclude_paths` regexes or `swagger_doc { exclude true }`.

## Does it replace rswag contract tests?

No. It replaces documentation maintenance burden. Keep contract tests if you rely on them for response validation.

## What OpenAPI version is generated?

OpenAPI 3.0.3.
