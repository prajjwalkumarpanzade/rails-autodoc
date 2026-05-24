# frozen_string_literal: true

require "spec_helper"

RSpec.describe "RailsAutodoc annotation DSL" do
  let(:generator) { RailsAutodoc::Generator.new }

  before do
    annotated_controller = Class.new(ActionController::API) do
      include RailsAutodoc::DSL::ControllerExtensions

      def self.name
        "Api::V1::UsersController"
      end

      def create
        head :created
      end

      swagger_doc action: :create do
        summary "Create a user"
        description "Creates a user with validated params"
        tag "Users"
        deprecated true
        body_param :role, :string, enum: %w[admin user]
        query_param :include, :string, required: true
        response 201, ref: "User", description: "Created"
        response 422, ref: "ValidationError", description: "Invalid"
        security :bearer_auth
      end
    end

    stub_const("Api::V1::UsersController", annotated_controller)

    RailsAutodoc.configure do |config|
      config.default_security = nil
    end

    Rails.application.routes.draw do
      namespace :api do
        namespace :v1 do
          resources :users, only: :create
        end
      end
    end
  end

  it "applies DSL overrides to generated operations" do
    operation = generator.generate.dig("paths", "/api/v1/users", "post")

    expect(operation["summary"]).to eq("Create a user")
    expect(operation["description"]).to eq("Creates a user with validated params")
    expect(operation["deprecated"]).to be(true)
    expect(operation["tags"]).to include("Users")
    expect(operation["security"]).to eq([{ "bearer_auth" => [] }])

    role_schema = operation.dig("requestBody", "content", "application/json", "schema", "properties", "role")
    expect(role_schema).to include("type" => "string", "enum" => %w[admin user])

    include_param = operation["parameters"].find { |entry| entry["name"] == "include" }
    expect(include_param).to include("in" => "query", "required" => true)

    expect(operation.dig("responses", "201", "description")).to eq("Created")
    expect(operation.dig("responses", "201", "content", "application/json", "schema",
                         "$ref")).to eq("#/components/schemas/User")
    expect(operation.dig("responses", "422", "content", "application/json", "schema",
                         "$ref")).to eq("#/components/schemas/ValidationError")
  end

  it "excludes operations when annotated with exclude" do
    RailsAutodoc.registry.register(Api::V1::UsersController, :create) do
      exclude true
    end

    expect(generator.generate.dig("paths", "/api/v1/users", "post")).to be_nil
  end
end
