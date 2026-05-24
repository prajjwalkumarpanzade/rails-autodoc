# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task default: :spec

task :environment do
  require "rails"
  require "rails_autodoc"
  require "combustion"

  Combustion.path = "spec/dummy"
  Combustion.initialize! :all unless Combustion::Application.initialized?
end

load File.expand_path("lib/rails_autodoc/tasks/autodoc.rake", __dir__)

namespace :appraisal do
  desc "Run specs against all Rails versions"
  task :spec do
    sh "bundle exec appraisal rake spec"
  end
end
