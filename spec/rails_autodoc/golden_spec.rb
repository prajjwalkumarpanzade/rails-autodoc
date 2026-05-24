# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Golden OpenAPI fixtures" do
  before do
    users_controller = Class.new(ActionController::API) do
      def self.name
        "Api::V1::UsersController"
      end

      def index
        render json: User.all
      end

      def create
        user = User.new(user_params)
        render json: user, status: :created
      end

      private

      def user_params
        params.require(:user).permit(:name, :email, :age, address: %i[street city], tags: [])
      end
    end

    stub_const("Api::V1::UsersController", users_controller)

    Rails.application.routes.draw do
      namespace :api do
        namespace :v1 do
          resources :users, only: %i[index create]
        end
      end
    end
  end

  it "matches expected create request schema fields" do
    spec = RailsAutodoc::Generator.new.generate
    post_operation = spec.dig("paths", "/api/v1/users", "post")
    user_schema = post_operation.dig("requestBody", "content", "application/json", "schema", "properties", "user",
                                     "properties")

    expect(user_schema.keys).to include("name", "email", "age", "address", "tags")
    expect(user_schema["age"]["type"]).to eq("integer")
  end

  it "matches key sections from the golden fixture" do
    expected = YAML.safe_load(
      File.read(File.expand_path("../fixtures/expected_specs/users_index_create.yaml", __dir__)),
      permitted_classes: [Date, Time]
    )
    actual = RailsAutodoc::Generator.new.generate

    expect(actual.dig("paths", "/api/v1/users", "get", "responses", "200")).to be_present
    expect(actual.dig("paths", "/api/v1/users", "post", "requestBody", "required")).to be(true)
    expect(actual.dig("paths", "/api/v1/users", "post", "responses", "201")).to be_present

    expected_post_schema = expected.dig("paths", "/api/v1/users", "post", "requestBody", "content", "application/json",
                                        "schema")
    actual_post_schema = actual.dig("paths", "/api/v1/users", "post", "requestBody", "content", "application/json",
                                    "schema")

    expect(actual_post_schema).to eq(expected_post_schema)
  end
end
