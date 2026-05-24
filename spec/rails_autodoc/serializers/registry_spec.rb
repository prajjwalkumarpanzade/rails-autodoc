# frozen_string_literal: true

require "spec_helper"

RSpec.describe RailsAutodoc::Serializers::Registry do
  let(:registry) { described_class.new }

  describe "Blueprinter adapter" do
    let(:serializer_class) do
      Class.new do
        def self.name
          "UserBlueprint"
        end

        def self.fields
          { id: {}, email: {}, name: {} }
        end
      end
    end

    before do
      stub_const("Blueprinter", Module.new)
      stub_const("Blueprinter::Base", Class.new)
    end

    it "builds schema from serializer fields" do
      adapter = RailsAutodoc::Serializers::Blueprinter.new
      allow(adapter).to receive(:detect?).and_return(true)
      schema = adapter.schema_for(serializer_class)
      expect(schema[:properties].keys).to include("id", "email", "name")
    end
  end
end
