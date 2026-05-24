# frozen_string_literal: true

require "yaml"
require "json"

module RailsAutodoc
  class Generator
    def initialize(config: RailsAutodoc.config)
      @config = config
    end

    def generate
      operations = RouteInspector.new(config: @config).operations
      OpenapiSpecBuilder.new(operations: operations, config: @config).build
    end

    def generate!
      spec = generate
      write_spec(spec)
      spec
    end

    def write_spec(spec)
      output_path = @config.resolved_output_path
      output_path.dirname.mkpath
      output_path.write(YAML.dump(spec))
      spec
    end

    def to_json(*_args)
      JSON.pretty_generate(generate)
    end

    def verify!
      output_path = @config.resolved_output_path
      current = output_path.exist? ? YAML.safe_load(output_path.read, permitted_classes: [Date, Time]) : {}
      fresh = generate

      unless normalize_spec(current) == normalize_spec(fresh)
        raise SpecDriftError, "OpenAPI spec drift detected at #{output_path}. Run `rake autodoc:generate`."
      end

      true
    end

    private

    def normalize_spec(spec)
      JSON.pretty_generate(spec)
    end
  end

  class SpecDriftError < StandardError; end
end
