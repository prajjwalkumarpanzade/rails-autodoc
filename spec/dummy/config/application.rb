# frozen_string_literal: true

require "rails/all"
Bundler.require(*Rails.groups)
require "rails_autodoc"

module Dummy
  class Application < Rails::Application
    config.load_defaults Rails::VERSION::STRING.to_f >= 7.0 ? "7.1" : "6.1"
    config.eager_load = false
    config.secret_key_base = "0" * 64
    config.active_record.maintain_test_schema = true
  end
end
