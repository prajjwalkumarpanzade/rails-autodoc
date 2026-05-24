# frozen_string_literal: true

RailsAutodoc.configure do |config|
  config.title = "Dummy API"
  config.version = "1.0.0"
  config.output_path = Rails.root.join("tmp/openapi.yaml")
  config.exclude_paths = [%r{^/rails/}, %r{^/api-docs}]
end
