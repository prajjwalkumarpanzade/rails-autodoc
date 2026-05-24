# frozen_string_literal: true

module RailsAutodoc
  module DSL
    module ControllerExtensions
      extend ActiveSupport::Concern

      class_methods do
        def swagger_doc(action:, &block)
          RailsAutodoc.registry.register(self, action, &block)
        end
      end

      class AnnotationBuilder
        def initialize(annotation)
          @annotation = annotation
        end

        def summary(text)
          @annotation.summary = text
        end

        def description(text)
          @annotation.description = text
        end

        def tag(*tags)
          @annotation.tags.concat(tags.map(&:to_s))
        end

        def deprecated(value = true)
          @annotation.deprecated = value
        end

        def exclude(value = true)
          @annotation.exclude = value
        end

        def body_param(name, type, options = {})
          @annotation.body_params << { name: name.to_s, type: type.to_s }.merge(options)
        end

        def query_param(name, type, options = {})
          @annotation.query_params << {
            name: name.to_s,
            type: type.to_s,
            required: options.fetch(:required, false)
          }.merge(options)
        end

        def response(status, options = {})
          @annotation.responses[status.to_s] = options
        end

        def security(scheme)
          @annotation.security = scheme
        end

        def request_body(schema)
          @annotation.request_body_schema = schema
        end
      end
    end
  end
end
