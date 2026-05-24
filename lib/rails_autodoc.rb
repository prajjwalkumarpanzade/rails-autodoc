# frozen_string_literal: true

require "json"
require "pathname"
require "yaml"

require "active_support"
require "active_support/core_ext/object/blank"
require "active_support/core_ext/string/inflections"
require "active_support/dependencies"

require_relative "rails_autodoc/version"
require_relative "rails_autodoc/ast_traversal"
require_relative "rails_autodoc/configuration"
require_relative "rails_autodoc/registry"
require_relative "rails_autodoc/route_inspector"
require_relative "rails_autodoc/strong_params_parser"
require_relative "rails_autodoc/schema_mapper"
require_relative "rails_autodoc/response_inferencer"
require_relative "rails_autodoc/serializers/registry"
require_relative "rails_autodoc/dsl/controller_extensions"
require_relative "rails_autodoc/openapi_spec_builder"
require_relative "rails_autodoc/generator"

module RailsAutodoc
  class << self
    def config
      @config ||= Configuration.new
    end

    def configure
      yield config
    end

    def registry
      @registry ||= Registry.new
    end

    def reset!
      @config = Configuration.new
      @registry = Registry.new
    end
  end
end

require_relative "rails_autodoc/railtie" if defined?(Rails)
require_relative "rails_autodoc/engine" if defined?(Rails)
