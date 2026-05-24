# frozen_string_literal: true

require "spec_helper"

RSpec.describe RailsAutodoc::ResponseInferencer do
  let(:source_path) { File.expand_path("../dummy/app/controllers/api/v1/users_controller.rb", __dir__) }

  subject(:inferencer) do
    described_class.new(source_path: source_path, class_name: "Api::V1::UsersController")
  end

  it "infers default GET response" do
    responses = inferencer.responses_for_action("index", verb: "GET")
    expect(responses.first.status).to eq("200")
  end

  it "infers POST created status from render call" do
    responses = inferencer.responses_for_action("create", verb: "POST")
    expect(responses.map(&:status)).to include("201")
  end

  it "infers DELETE no content" do
    responses = inferencer.responses_for_action("destroy", verb: "DELETE")
    expect(responses.map(&:status)).to include("204")
  end
end
