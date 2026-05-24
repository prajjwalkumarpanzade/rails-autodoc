# frozen_string_literal: true

source "https://rubygems.org"

gemspec

gem "rails", "~> 7.1"
gem "sqlite3", "~> 1.6.9"
# nokogiri 1.15.x does not support Ruby 3.3+ (main CI matrix only)
gem "nokogiri", ">= 1.16.8" if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new("3.3.0")
