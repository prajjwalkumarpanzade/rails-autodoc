# frozen_string_literal: true

RailsAutodoc.configure do |config|
  config.title = "<%= Rails.application.class.module_parent_name %> API"
  config.version = "1.0.0"
  config.description = "Auto-generated API documentation"
  config.mount_path = "/api-docs"
  config.output_path = Rails.root.join("openapi/openapi.yaml")
  config.exclude_paths = [%r{^/rails/}, %r{^/api-docs}]
  config.cache_spec_in_dev = true

  # config.security_schemes = {
  #   "bearer_auth" => {
  #     "type" => "http",
  #     "scheme" => "bearer",
  #     "bearerFormat" => "JWT"
  #   }
  # }
  # config.default_security = :bearer_auth
end
