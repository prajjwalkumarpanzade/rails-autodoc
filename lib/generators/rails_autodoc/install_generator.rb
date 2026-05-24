# frozen_string_literal: true

require "rails/generators"

module RailsAutodoc
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      desc "Install rails-autodoc configuration, output directory, and optional CI workflow"

      def create_initializer
        template "initializer.rb", "config/initializers/rails_autodoc.rb"
      end

      def create_output_directory
        empty_directory "openapi"
        create_file "openapi/.keep"
      end

      def mount_engine
        route <<~ROUTE

          # Auto-generated API documentation (development/staging recommended)
          mount RailsAutodoc::Engine => "/api-docs"
        ROUTE
      end

      def create_ci_workflow
        template "autodoc-verify.yml", ".github/workflows/autodoc-verify.yml"
      end
    end
  end
end
