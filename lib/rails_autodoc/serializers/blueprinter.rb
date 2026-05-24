# frozen_string_literal: true

module RailsAutodoc
  module Serializers
    class Blueprinter < Base
      def detect?
        defined?(::Blueprinter)
      end

      def attributes_for(serializer_class)
        if serializer_class.respond_to?(:fields)
          serializer_class.fields.keys.map(&:to_s)
        else
          []
        end
      end

      def schema_for(serializer_class)
        properties = attributes_for(serializer_class).to_h do |field|
          [field, { type: "string" }]
        end

        { type: "object", properties: properties }
      end
    end
  end
end
