# frozen_string_literal: true

require "spec_helper"

RSpec.describe RailsAutodoc::Registry do
  controller_class = Class.new do
    def self.name
      "DocsController"
    end
  end

  it "registers annotation overrides" do
    RailsAutodoc.registry.register(controller_class, :create) do
      summary "Create resource"
      tag "Docs"
      body_param :role, :string, enum: %w[admin user]
      response 201, ref: "User"
    end

    annotation = RailsAutodoc.registry.find(controller_class, :create)
    expect(annotation.summary).to eq("Create resource")
    expect(annotation.tags).to include("Docs")
    expect(annotation.body_params.first[:enum]).to eq(%w[admin user])
    expect(annotation.responses["201"][:ref]).to eq("User")
  end
end
