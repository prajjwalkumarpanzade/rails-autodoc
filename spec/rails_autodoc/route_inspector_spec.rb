# frozen_string_literal: true

require "spec_helper"

RSpec.describe RailsAutodoc::RouteInspector do
  subject(:operations) { described_class.new.operations }

  before do
    users_controller = Class.new(ActionController::API) do
      def self.name
        "Api::V1::UsersController"
      end

      def index
        head :ok
      end

      def show
        head :ok
      end

      def create
        head :ok
      end
    end

    stub_const("Api::V1::UsersController", users_controller)

    Rails.application.routes.draw do
      namespace :api do
        namespace :v1 do
          resources :users, only: %i[index show create]
        end
      end
    end
  end

  it "discovers REST routes" do
    expect(operations.map(&:verb)).to include("GET", "POST")
  end

  it "extracts path parameters" do
    show_operation = operations.find { |op| op.action == "show" }
    expect(show_operation.path_params).to include("id")
  end

  it "normalizes OpenAPI path templates" do
    show_operation = operations.find { |op| op.action == "show" }
    expect(show_operation.openapi_path).to eq("/api/v1/users/{id}")
  end

  it "assigns controller tags" do
    operation = operations.find { |op| op.action == "index" }
    expect(operation.tags).to include("Users")
  end
end
