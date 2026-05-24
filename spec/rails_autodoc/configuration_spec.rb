# frozen_string_literal: true

require "spec_helper"

RSpec.describe RailsAutodoc::Configuration do
  subject(:config) { described_class.new }

  it "defines sensible defaults" do
    expect(config.title).to eq("Rails API")
    expect(config.version).to eq("1.0.0")
    expect(config.mount_path).to eq("/api-docs")
    expect(config.cache_spec_in_dev).to be(true)
    expect(config.exclude_paths).not_to be_empty
  end

  it "matches excluded paths against patterns" do
    expect(config.excluded_path?("/rails/info")).to be(true)
    expect(config.excluded_path?("/api-docs/spec.json")).to be(true)
    expect(config.excluded_path?("/api/v1/users")).to be(false)
  end

  it "resolves output path from config when set" do
    custom_path = Rails.root.join("tmp/custom-openapi.yaml")
    config.output_path = custom_path

    expect(config.resolved_output_path).to eq(custom_path)
  end

  it "falls back to openapi/openapi.yaml under Rails.root" do
    config.output_path = nil

    expect(config.resolved_output_path).to eq(Rails.root.join("openapi/openapi.yaml"))
  end
end
