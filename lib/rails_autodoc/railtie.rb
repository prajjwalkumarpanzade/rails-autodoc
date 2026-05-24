# frozen_string_literal: true

module RailsAutodoc
  class Railtie < Rails::Railtie
    rake_tasks do
      load "rails_autodoc/tasks/autodoc.rake"
    end

    initializer "rails_autodoc.configure" do
      if Rails.root.join("config/initializers/rails_autodoc.rb").exist?
        require Rails.root.join("config/initializers/rails_autodoc.rb")
      end
    end

    initializer "rails_autodoc.dsl" do
      ActiveSupport.on_load(:action_controller) do
        include RailsAutodoc::DSL::ControllerExtensions
      end
    end

    config.to_prepare do
      RailsAutodoc.registry.clear! if Rails.env.development?
    end
  end
end
