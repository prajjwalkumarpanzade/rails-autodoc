# CI Integration

Prevent documentation drift by verifying the committed OpenAPI file matches generated output.

## Local verify

```bash
rake autodoc:generate
rake autodoc:verify
```

## GitHub Actions

The install generator adds `.github/workflows/autodoc-verify.yml`:

```yaml
- run: bundle exec rake autodoc:verify
```

## Recommended workflow

1. Commit `openapi/openapi.yaml`
2. Run `autodoc:verify` in CI on every pull request
3. Regenerate locally when routes or strong params change

## Debugging inferred routes

```bash
rake autodoc:routes
```

Prints verb, path, controller, and action for every discovered operation.
