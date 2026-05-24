# frozen_string_literal: true

require "spec_helper"

RSpec.describe "RailsAutodoc integration", type: :request do
  let(:generator) { RailsAutodoc::Generator.new }
  let(:spec) { generator.generate }

  before do
    RailsAutodoc.configure do |config|
      config.title = "Dummy API"
      config.version = "1.0.0"
      config.output_path = Rails.root.join("tmp/openapi.yaml")
    end

    Rails.application.routes.draw do
      mount RailsAutodoc::Engine => "/api-docs"
      namespace :api do
        namespace :v1 do
          resources :users, only: %i[index show create update destroy]
        end
      end
    end
  end

  it "loads the published gem version" do
    expect(RailsAutodoc::VERSION).to match(/\A\d+\.\d+\.\d+\z/)
  end

  it "generates a complete OpenAPI document" do
    expect(spec).to include("openapi", "info", "servers", "tags", "paths", "components")
    expect(spec["openapi"]).to eq("3.0.3")
    expect(spec.dig("info", "title")).to eq("Dummy API")
    expect(spec.dig("info", "version")).to eq("1.0.0")
    expect(spec["servers"]).not_to be_empty
    expect(spec["tags"]).not_to be_empty
  end

  it "documents CRUD user paths" do
    expect(spec["paths"].keys).to include("/api/v1/users", "/api/v1/users/{id}")
    expect(spec.dig("paths", "/api/v1/users", "get", "operationId")).to eq("api_v1_users_controller_index")
    expect(spec.dig("paths", "/api/v1/users", "post", "operationId")).to eq("api_v1_users_controller_create")
  end

  it "documents path parameters for member routes" do
    parameters = spec.dig("paths", "/api/v1/users/{id}", "get", "parameters")
    id_param = parameters.find { |entry| entry["name"] == "id" }

    expect(id_param).to include("in" => "path", "required" => true)
    expect(id_param.dig("schema", "type")).to eq("string")
  end

  it "documents nested strong params on create" do
    user_schema = spec.dig(
      "paths", "/api/v1/users", "post",
      "requestBody", "content", "application/json", "schema",
      "properties", "user", "properties"
    )

    expect(user_schema.keys).to include("name", "email", "age", "address", "tags")
    expect(user_schema["age"]["type"]).to eq("integer")
    expect(user_schema["address"]["type"]).to eq("object")
    expect(user_schema["tags"]["type"]).to eq("array")
  end

  it "infers response status codes from controller actions" do
    expect(spec.dig("paths", "/api/v1/users", "post", "responses").keys).to include("201", "422")
    expect(spec.dig("paths", "/api/v1/users/{id}", "delete", "responses").keys).to include("204")
  end

  it "includes User schema in components" do
    user_component = spec.dig("components", "schemas", "User")

    expect(user_component).to include("type" => "object")
    expect(user_component).to have_key("properties")
    expect(user_component["properties"].keys).to include("name", "email", "age", "active")
  end

  it "does not document excluded mount paths" do
    expect(spec["paths"].keys).not_to include("/api-docs")
    expect(spec["paths"].keys).not_to include("/api-docs/spec.json")
  end

  it "raises when generated output drifts from committed file" do
    output_path = RailsAutodoc.config.resolved_output_path
    original = output_path.exist? ? output_path.read : nil
    generator.generate!

    expect { generator.verify! }.not_to raise_error

    output_path.write("openapi: 3.0.3\ninfo:\n  title: Changed\n")

    expect { generator.verify! }.to raise_error(
      RailsAutodoc::SpecDriftError,
      /OpenAPI spec drift detected/
    )
  ensure
    if original
      output_path.write(original)
    elsif output_path.exist?
      output_path.delete
    end
  end

  it "serves generated operations over HTTP" do
    get "/api-docs/spec.json"

    expect(response).to have_http_status(:ok)

    body = JSON.parse(response.body)
    expect(body.dig("paths", "/api/v1/users", "post", "requestBody")).not_to be_nil
    expect(body.dig("components", "schemas", "User", "properties", "email", "type")).to eq("string")
  end
end
