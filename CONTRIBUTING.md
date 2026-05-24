# Contributing to rails-autodoc

Thank you for contributing. This gem generates OpenAPI documentation from Rails conventions, so changes should preserve backward compatibility across Rails 5.2 through 8.x whenever possible.

## Development setup

```bash
git clone https://github.com/example/rails-autodoc.git
cd rails-autodoc
bundle install
bundle exec rspec
```

## Testing against multiple Rails versions

```bash
bundle exec appraisal install
bundle exec appraisal rake spec
```

The Combustion dummy app lives in `spec/dummy/`.

## Adding AST fixture cases

1. Add a controller snippet under `spec/fixtures/controllers/`
2. Add expectations in `spec/rails_autodoc/strong_params_parser_spec.rb`
3. If output changes globally, update golden files in `spec/fixtures/expected_specs/`

## Adding a serializer adapter

1. Create `lib/rails_autodoc/serializers/your_adapter.rb`
2. Subclass `RailsAutodoc::Serializers::Base`
3. Register it in `lib/rails_autodoc/serializers/registry.rb`
4. Add unit tests under `spec/rails_autodoc/serializers/`

## Code style

- Run `bundle exec rubocop` before opening a PR
- Keep public APIs documented with YARD comments
- Prefer small, focused classes over large monoliths

## Documentation

- Update `README.md` for user-facing changes
- Update relevant pages under `docs/` for behavior or configuration changes
- Add entries to `CHANGELOG.md` under `[Unreleased]`

## Pull request checklist

- [ ] Specs pass locally (`bundle exec rspec`)
- [ ] Appraisal matrix passes for affected Rails versions
- [ ] `bundle exec rake autodoc:verify` passes on the dummy app
- [ ] Documentation updated
- [ ] CHANGELOG updated
