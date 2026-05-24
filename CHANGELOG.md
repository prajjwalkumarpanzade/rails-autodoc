All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2026-05-24

### Added

- Initial release of `rails-autodoc`
- Automatic OpenAPI 3.0.3 generation from Rails routes, strong params, and `db/schema.rb`
- AST-based `permit(...)` extraction for request body schemas
- Response inference from `render json:` and `head` calls
- Serializer adapters for Alba, Blueprinter, and ActiveModel::Serializer
- Optional `swagger_doc` annotation DSL for overrides
- Swagger UI engine mount at `/api-docs`
- Rake tasks: `autodoc:generate`, `autodoc:verify`, `autodoc:routes`
- Install generator: `rails generate rails_autodoc:install`
- Rails 5.2 through 8.x Appraisal test matrix
- Documentation site and contributor guides
