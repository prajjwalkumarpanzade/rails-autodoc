# frozen_string_literal: true

require_relative "lib/rails_autodoc/version"

DEFAULT_GEM_FILES = Dir[
  "{app,config,docs,lib}/**/*",
  "README.md",
  "CHANGELOG.md",
  "LICENSE.txt",
  "Rakefile"
].select { |file| File.file?(File.join(__dir__, file)) }.freeze

Gem::Specification.new do |spec|
  spec.name = "rails-autodoc"
  spec.version = RailsAutodoc::VERSION
  spec.authors = ["Prajjwalkumar Panzade"]
  spec.email = ["prajjwalbpanzade22@gmail.com"]

  spec.summary = "Auto-generate OpenAPI documentation from Rails routes, strong params, and schemas"
  spec.description = "Generate and serve OpenAPI 3.0 specs from Rails conventions with optional annotation overrides."
  spec.homepage = "https://github.com/example/rails-autodoc"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.7.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = Dir.chdir(__dir__) do
    files = begin
      `git ls-files -z`.split("\x0")
    rescue StandardError
      []
    end

    files = DEFAULT_GEM_FILES if files.empty?

    files.reject do |file|
      file.start_with?("spec/fixtures/") || file.end_with?(".gem")
    end
  end

  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport", ">= 5.2", "< 9"
  spec.add_dependency "parser", "~> 3.3"
  spec.add_dependency "psych", ">= 3.1"
  spec.add_dependency "railties", ">= 5.2", "< 9"

  spec.add_development_dependency "appraisal"
  spec.add_development_dependency "combustion", "~> 1.4"
  spec.add_development_dependency "rails", ">= 5.2", "< 9"
  spec.add_development_dependency "rspec", "~> 3.12"
  spec.add_development_dependency "rspec-rails"
  spec.add_development_dependency "rubocop", "~> 1.60"
  spec.add_development_dependency "sqlite3", ">= 1.4", "< 1.7"
  spec.add_development_dependency "webmock"
end
