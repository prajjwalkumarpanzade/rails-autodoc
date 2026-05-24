# frozen_string_literal: true

require "spec_helper"

RSpec.describe RailsAutodoc::Generator do
  subject(:generator) { described_class.new }

  before do
    Rails.application.routes.draw do
      mount RailsAutodoc::Engine => "/api-docs"
      namespace :api do
        namespace :v1 do
          resources :users, only: %i[index show create update destroy]
        end
      end
    end
  end

  it "generates a valid OpenAPI document" do
    spec = generator.generate
    expect(spec["openapi"]).to eq("3.0.3")
    expect(spec["paths"]).not_to be_empty
  end

  it "includes user paths" do
    spec = generator.generate
    expect(spec["paths"].keys).to include("/api/v1/users", "/api/v1/users/{id}")
  end

  it "writes spec to configured output path" do
    generator.generate!
    expect(RailsAutodoc.config.resolved_output_path).to exist
  end

  it "verifies unchanged specs" do
    generator.generate!
    expect { generator.verify! }.not_to raise_error
  end
end
