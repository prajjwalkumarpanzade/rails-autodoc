# frozen_string_literal: true

require "spec_helper"

RSpec.describe "RailsAutodoc gem packaging" do
  it "builds a non-empty gemspec file list" do
    gemspec = Gem::Specification.load("rails-autodoc.gemspec")

    expect(gemspec.files).not_to be_empty
    expect(gemspec.files).to include("lib/rails_autodoc.rb")
    expect(gemspec.files).to include("lib/rails_autodoc/generator.rb")
    expect(gemspec.files).to include("README.md")
  end

  it "requires Ruby 2.7 or newer" do
    gemspec = Gem::Specification.load("rails-autodoc.gemspec")

    expect(gemspec.required_ruby_version).to eq(Gem::Requirement.new(">= 2.7.0"))
  end

  it "declares runtime dependencies needed for inference" do
    gemspec = Gem::Specification.load("rails-autodoc.gemspec")
    names = gemspec.dependencies.map(&:name)

    expect(names).to include("activesupport", "parser", "psych", "railties")
  end
end
