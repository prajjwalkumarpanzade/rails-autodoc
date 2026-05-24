# frozen_string_literal: true

module RailsAutodoc
  module Serializers
    class Base
      def detect?
        false
      end

      def attributes_for(_serializer_class)
        []
      end

      def schema_for(_serializer_class)
        { type: "object" }
      end
    end
  end
end
