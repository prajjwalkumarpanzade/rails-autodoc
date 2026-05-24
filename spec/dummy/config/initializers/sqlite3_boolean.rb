# frozen_string_literal: true

# Rails 5.2 stores sqlite booleans as 't'/'f' by default; use integer 1/0 instead.
if Gem::Version.new(Rails.version) < Gem::Version.new("6.0")
  ActiveSupport.on_load(:active_record_sqlite3adapter) do
    ActiveRecord::ConnectionAdapters::SQLite3Adapter.represent_boolean_as_integer = true
  end
end
