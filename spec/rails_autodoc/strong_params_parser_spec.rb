# frozen_string_literal: true

require "spec_helper"

RSpec.describe RailsAutodoc::StrongParamsParser do
  let(:source_path) { File.expand_path("../fixtures/controllers/sample_controller.rb", __dir__) }

  subject(:parser) do
    described_class.new(source_path: source_path, class_name: "SampleController")
  end

  it "extracts param methods" do
    methods = parser.param_methods
    expect(methods).to have_key("sample_params")
  end

  it "parses required root key" do
    result = parser.param_methods["sample_params"]
    expect(result.root_key).to eq(:sample)
  end

  it "parses scalar permitted fields" do
    properties = parser.param_methods["sample_params"].schema[:properties]
    expect(properties).to include("name", "email")
  end

  it "parses nested hash fields" do
    properties = parser.param_methods["sample_params"].schema[:properties]
    expect(properties["address"][:type]).to eq("object")
  end

  it "parses array fields" do
    properties = parser.param_methods["sample_params"].schema[:properties]
    expect(properties["tags"][:type]).to eq("array")
  end

  it "maps params to actions" do
    result = parser.params_for_action("create")
    expect(result.method_name).to eq("sample_params")
  end
end
