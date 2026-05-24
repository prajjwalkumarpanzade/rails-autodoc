# frozen_string_literal: true

require "spec_helper"

RSpec.describe RailsAutodoc::SchemaMapper do
  let(:schema_path) { Rails.root.join("db/schema.rb") }

  subject(:mapper) { described_class.new(schema_path: schema_path) }

  it "loads tables from schema.rb" do
    expect(mapper.all_model_schemas).to have_key("User")
  end

  it "maps string columns" do
    schema = mapper.model_schema("User")
    expect(schema[:properties]["name"][:type]).to eq("string")
  end

  it "maps integer columns" do
    schema = mapper.model_schema("User")
    expect(schema[:properties]["age"][:type]).to eq("integer")
  end

  it "maps boolean columns" do
    schema = mapper.model_schema("User")
    expect(schema[:properties]["active"][:type]).to eq("boolean")
  end

  it "applies model types to param schemas" do
    param_schema = {
      type: "object",
      properties: {
        "name" => { type: "string" },
        "age" => { type: "string" }
      },
      required: []
    }

    mapper.apply_types!(param_schema, model_name: "User")
    expect(param_schema[:properties]["age"][:type]).to eq("integer")
  end
end
