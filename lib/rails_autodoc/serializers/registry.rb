# frozen_string_literal: true

require_relative "base"
require_relative "alba"
require_relative "blueprinter"
require_relative "active_model_serializer"

module RailsAutodoc
  module Serializers
    class Registry
      ADAPTERS = [
        Alba.new,
        Blueprinter.new,
        ActiveModelSerializer.new
      ].freeze

      def active_adapters
        ADAPTERS.select(&:detect?)
      end

      def schema_for(serializer_class)
        adapter = active_adapters.find do |candidate|
          candidate.schema_for(serializer_class).fetch(:properties, {}).any?
        end
        adapter ? adapter.schema_for(serializer_class) : { type: "object" }
      end
    end
  end
end
