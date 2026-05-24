# rails-autodoc

Auto-generate OpenAPI 3.0 documentation from Rails routes, strong params, database schemas, and serializers.

**Problem:** Tools like rswag require maintaining RSpec specs that drift in legacy projects.

**Solution:** `rails-autodoc` reads the code you already maintain to ship features: `routes.rb`, `permit(...)`, and `db/schema.rb`.

## Quick start

Add to your Gemfile:

```ruby
gem "rails-autodoc", group: :development
```

Install:

```bash
bundle install
rails generate rails_autodoc:install
rake autodoc:generate
```

Open interactive docs:

```
http://localhost:3000/api-docs
```

## What gets generated automatically

| Feature | Support |
|---------|---------|
| Paths and HTTP verbs | Yes |
| Path parameters | Yes |
| Request body fields from strong params | Yes |
| Request field types from DB schema | Best effort |
| Query params from `params[:foo]` usage | Best effort |
| Response schemas | Serializer-aware, best effort |
| Validation rules / enums | Via annotation DSL |

## Configuration

```ruby
# config/initializers/rails_autodoc.rb
RailsAutodoc.configure do |config|
  config.title = "My API"
  config.version = "1.0.0"
  config.mount_path = "/api-docs"
  config.output_path = Rails.root.join("openapi/openapi.yaml")
  config.exclude_paths = [%r{^/rails/}, %r{^/api-docs}]
end
```

## Annotation DSL (optional)

Use when inference is not enough:

```ruby
class Api::V1::UsersController < ApplicationController
  swagger_doc action: :create do
    summary "Create a user"
    body_param :role, :string, enum: %w[admin user]
    response 201, ref: "User"
    response 422, ref: "ValidationError"
  end
end
```

## Rake tasks

| Task | Description |
|------|-------------|
| `rake autodoc:generate` | Write OpenAPI YAML to configured output path |
| `rake autodoc:verify` | Fail if generated spec differs from committed file |
| `rake autodoc:routes` | Print inferred operations |

## CI integration

```yaml
- run: bundle exec rake autodoc:verify
```

## Comparison

| Tool | Approach | Maintenance |
|------|----------|-------------|
| FastAPI | Types are the spec | Zero drift |
| rswag | RSpec DSL drives docs | High |
| swagger-blocks | Manual annotations | High |
| rails-autodoc | Convention inference | Low |

## Rails compatibility

Officially tested with Rails 5.2, 6.1, 7.0, 7.1, and 8.0 via Appraisal.

## Documentation

Full docs live in [`docs/`](docs/index.md):

- [Getting Started](docs/getting-started.md)
- [Configuration](docs/configuration.md)
- [Inference Rules](docs/inference-rules.md)
- [Annotation DSL](docs/annotation-dsl.md)
- [Limitations](docs/limitations.md)
- [Migration from rswag](docs/migration-from-rswag.md)

## License

MIT — see [LICENSE.txt](LICENSE.txt).
