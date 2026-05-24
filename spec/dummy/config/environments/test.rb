# frozen_string_literal: true

Rails.application.configure do
  config.cache_classes = false
  config.eager_load = false
  config.public_file_server.enabled = true
  config.public_file_server.headers = { "Cache-Control" => "public, max-age=3600" }
  config.consider_all_requests_local = true
  config.action_controller.perform_caching = false
  config.active_support.deprecation = :stderr
  config.active_record.migration_error = :page_load

  # Rails 5.2 sqlite3 adapter: store booleans as integers (see sqlite3 gem docs).
  config.active_record.sqlite3 = { represent_boolean_as_integer: true } if Rails::VERSION::MAJOR < 6
end
