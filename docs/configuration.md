# Configuration

Configure the gem in `config/initializers/rails_autodoc.rb`:

```ruby
RailsAutodoc.configure do |config|
  config.title = "My App API"
  config.version = "1.0.0"
  config.description = "Auto-generated API documentation"
  config.mount_path = "/api-docs"
  config.output_path = Rails.root.join("openapi/openapi.yaml")
  config.exclude_paths = [%r{^/rails/}, %r{^/api-docs}]
  config.cache_spec_in_dev = true
end
```

## Options

| Option | Default | Description |
|--------|---------|-------------|
| `title` | `"Rails API"` | OpenAPI info title |
| `version` | `"1.0.0"` | OpenAPI info version |
| `description` | auto | OpenAPI info description |
| `mount_path` | `"/api-docs"` | Engine mount path |
| `output_path` | `openapi/openapi.yaml` | Static export path |
| `exclude_paths` | internal routes | Regex list of paths to skip |
| `include_engines` | `[]` | Additional engines to scan |
| `default_security` | `nil` | Default security scheme key |
| `security_schemes` | `{}` | OpenAPI security scheme definitions |
| `cache_spec_in_dev` | `true` | Cache live spec in development |
| `servers` | localhost | OpenAPI servers array |

## Security example

```ruby
config.security_schemes = {
  "bearer_auth" => {
    "type" => "http",
    "scheme" => "bearer",
    "bearerFormat" => "JWT"
  }
}
config.default_security = :bearer_auth
```

## Production guidance

Serve static `openapi/openapi.yaml` in production rather than mounting the engine publicly unless docs should be externally accessible.
