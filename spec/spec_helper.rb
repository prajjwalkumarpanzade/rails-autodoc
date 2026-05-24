# frozen_string_literal: true

require "rails"
require "rails_autodoc"
require "combustion"

Combustion.path = "spec/dummy"
Combustion.initialize! :all do
  sqlite3_config = config.active_record.sqlite3 if config.respond_to?(:active_record)
  sqlite3_config.represent_boolean_as_integer = true if sqlite3_config.respond_to?(:represent_boolean_as_integer=)
end

[Rails.root.join("app/models"), Rails.root.join("app/controllers")].each do |load_path|
  Dir[load_path.join("**", "*.rb")].sort.each { |path| require path }
end

require "rspec/rails"

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.filter_run_when_matching :focus
  config.example_status_persistence_file_path = "spec/examples.txt"
  config.disable_monkey_patching!
  config.order = :random
  Kernel.srand config.seed

  config.before(:each) do
    RailsAutodoc.registry.clear!
    load Rails.root.join("config/initializers/rails_autodoc.rb")
    clear_spec_controller_cache
  end
end

def clear_spec_controller_cache
  return unless defined?(RailsAutodoc::SpecController)

  RailsAutodoc::SpecController.cached_spec = nil
end
