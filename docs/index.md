# rails-autodoc

Generate OpenAPI 3.0 documentation from Rails conventions — routes, strong params, database schemas, and serializers.

## Why this gem exists

Legacy Rails APIs often have outdated rswag specs. `rails-autodoc` generates docs from files teams already update to ship features:

- `config/routes.rb`
- `params.require(...).permit(...)`
- `db/schema.rb`

## Features

- Zero-config baseline documentation
- Optional `swagger_doc` DSL for edge cases
- Swagger UI at `/api-docs`
- CI drift detection via `rake autodoc:verify`
- Rails 5.2 through 8.x support

See [Getting Started](getting-started.md) to install the gem.
