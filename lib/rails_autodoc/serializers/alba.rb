# frozen_string_literal: true

module RailsAutodoc
  module Serializers
    class Alba < Base
      def detect?
        defined?(::Alba)
      end

      def attributes_for(serializer_class)
        serializer_class.instance_methods(false).grep(/^[a-z]/) +
          extract_alba_attributes(serializer_class)
      rescue StandardError
        []
      end

      def schema_for(serializer_class)
        fields = extract_alba_attributes(serializer_class)
        properties = fields.to_h do |field|
          [field.to_s, { type: "string" }]
        end

        { type: "object", properties: properties }
      end

      private

      def extract_alba_attributes(serializer_class)
        if serializer_class.respond_to?(:attributes)
          serializer_class.attributes.keys.map(&:to_s)
        elsif serializer_class.respond_to?(:_attributes)
          serializer_class._attributes.keys.map(&:to_s)
        else
          []
        end
      end
    end
  end
end
