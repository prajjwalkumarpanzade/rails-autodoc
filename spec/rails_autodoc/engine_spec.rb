# frozen_string_literal: true

require "spec_helper"

RSpec.describe "RailsAutodoc::Engine", type: :request do
  before do
    Rails.application.routes.draw do
      mount RailsAutodoc::Engine => "/api-docs"
      get "/health", to: proc { [200, {}, ["ok"]] }
    end
  end

  it "serves Swagger UI" do
    get "/api-docs/"
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("swagger-ui")
  end

  it "serves generated OpenAPI JSON" do
    get "/api-docs/spec.json"
    expect(response).to have_http_status(:ok)
    expect(response.media_type).to include("json")
    body = JSON.parse(response.body)
    expect(body["openapi"]).to eq("3.0.3")
  end
end
