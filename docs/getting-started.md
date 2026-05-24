# Getting Started

## Installation

Add the gem to your Gemfile:

```ruby
gem "rails-autodoc", group: :development
```

Run Bundler:

```bash
bundle install
```

## Install generator

```bash
rails generate rails_autodoc:install
```

This creates:

- `config/initializers/rails_autodoc.rb`
- `openapi/` output directory
- Engine mount at `/api-docs`
- `.github/workflows/autodoc-verify.yml`

## Generate documentation

```bash
rake autodoc:generate
```

Output defaults to `openapi/openapi.yaml`.

## View interactive docs

Start Rails and visit:

```
http://localhost:3000/api-docs
```

The engine serves Swagger UI and a live spec at `/api-docs/spec.json`.

## Verify in CI

```bash
rake autodoc:verify
```

Commit the generated YAML and run this task in CI to prevent documentation drift.
