# frozen_string_literal: true

module RailsAutodoc
  class Configuration
    attr_accessor :title,
                  :version,
                  :description,
                  :mount_path,
                  :output_path,
                  :exclude_paths,
                  :include_engines,
                  :default_security,
                  :cache_spec_in_dev,
                  :servers,
                  :security_schemes

    def initialize
      @title = "Rails API"
      @version = "1.0.0"
      @description = "Auto-generated API documentation"
      @mount_path = "/api-docs"
      @output_path = nil
      @exclude_paths = [%r{^/rails/}, %r{^/api-docs}]
      @include_engines = []
      @default_security = nil
      @cache_spec_in_dev = true
      @servers = []
      @security_schemes = {}
    end

    def excluded_path?(path)
      exclude_paths.any? { |pattern| pattern.match?(path) }
    end

    def resolved_output_path
      return output_path if output_path

      if defined?(Rails) && Rails.respond_to?(:root)
        Rails.root.join("openapi/openapi.yaml")
      else
        Pathname.new("openapi/openapi.yaml")
      end
    end
  end
end
