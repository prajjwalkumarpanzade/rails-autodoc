# frozen_string_literal: true

module RailsAutodoc
  class OperationAnnotation
    attr_accessor :controller,
                  :action,
                  :summary,
                  :description,
                  :tags,
                  :deprecated,
                  :body_params,
                  :query_params,
                  :responses,
                  :security,
                  :request_body_schema,
                  :exclude

    def initialize(controller:, action:)
      @controller = controller
      @action = action
      @summary = nil
      @description = nil
      @tags = []
      @deprecated = false
      @body_params = []
      @query_params = []
      @responses = {}
      @security = nil
      @request_body_schema = nil
      @exclude = false
    end

    def operation_id
      "#{controller.name.underscore.tr('/', '_')}_#{action}"
    end
  end

  class Registry
    def initialize
      @annotations = {}
    end

    def register(controller, action, &block)
      key = annotation_key(controller, action)
      annotation = (@annotations[key] ||= OperationAnnotation.new(
        controller: controller,
        action: action
      ))
      DSL::ControllerExtensions::AnnotationBuilder.new(annotation).instance_eval(&block)
      annotation
    end

    def find(controller, action)
      @annotations[annotation_key(controller, action)]
    end

    def all
      @annotations.values
    end

    def clear!
      @annotations.clear
    end

    private

    def annotation_key(controller, action)
      "#{controller.name}##{action}"
    end
  end
end
