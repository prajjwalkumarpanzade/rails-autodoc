# Limitations

`rails-autodoc` is convention-driven. It is not a replacement for contract-first API design.

## Known gaps

| Scenario | Behavior |
|----------|----------|
| `params.permit!` | Not parsed; empty or generic schema |
| Dynamic param keys | Not inferred |
| Params in service objects | Not inferred |
| GraphQL endpoints | Out of scope |
| Grape APIs | Out of scope for v1 |
| Conditional strong params | Best effort only |
| Complex serializer logic | Field list only, no computed attribute types |

## Accuracy expectations

- Baseline without annotations: ~60-70% useful coverage
- With light DSL overrides: ~90%+ for most REST APIs
- FastAPI/Pydantic parity: not a goal

## When to use annotations

- Enum values
- Custom response codes
- Authentication requirements
- Non-standard request bodies
- Hiding internal/debug endpoints

## When not to use this gem

- Public APIs requiring strict contract guarantees
- APIs with minimal Rails conventions
- Greenfield projects where OpenAPI-first tooling is available
