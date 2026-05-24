# frozen_string_literal: true

require_relative "../rails_autodoc" unless defined?(RailsAutodoc) && RailsAutodoc.respond_to?(:configure)

module RailsAutodoc
  class Engine < ::Rails::Engine
    isolate_namespace RailsAutodoc

    config.generators do |g|
      g.test_framework :rspec
    end
  end
end
