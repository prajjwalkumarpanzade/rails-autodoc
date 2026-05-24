# Migration from rswag

## Philosophy difference

| rswag | rails-autodoc |
|-------|---------------|
| Tests drive docs | Conventions drive docs |
| High accuracy when maintained | Good accuracy with low maintenance |
| Requires RSpec DSL | Works without extra specs |

## Coexistence

You can run both during migration:

1. Install `rails-autodoc`
2. Generate baseline docs with `rake autodoc:generate`
3. Compare against existing rswag output
4. Remove rswag once satisfied

## Mapping concepts

| rswag | rails-autodoc |
|-------|---------------|
| `path` | inferred from routes |
| `parameter` | inferred from strong params / query usage |
| `response` | inferred from render calls or `swagger_doc` |
| `swagger_helper` config | `RailsAutodoc.configure` |

## Recommended migration path for legacy apps

1. Run `rails generate rails_autodoc:install`
2. Generate docs on day one without changing controllers
3. Add `swagger_doc` only where inference is wrong
4. Add `autodoc:verify` to CI
5. Deprecate outdated rswag specs

## What you can delete after migration

- rswag request specs used only for documentation
- Manual swagger YAML maintained separately from code

Keep rswag if you also use it for contract testing against the generated spec.
