# frozen_string_literal: true

module RailsAutodoc
  class RouteOperation
    attr_reader :verb,
                :path,
                :controller_class,
                :action,
                :route_name,
                :path_params,
                :tags,
                :constraints

    def initialize(verb:, path:, controller_class:, action:, route_name:, path_params:, tags:, constraints: {})
      @verb = verb
      @path = path
      @controller_class = controller_class
      @action = action.to_s
      @route_name = route_name
      @path_params = path_params
      @tags = tags
      @constraints = constraints
    end

    def operation_id
      "#{controller_class.name.underscore.tr('/', '_')}_#{action}"
    end

    def openapi_path
      path.gsub(/:([a-zA-Z_][a-zA-Z0-9_]*)/, '{\1}')
    end
  end

  class RouteInspector
    HTTP_VERBS = %w[GET HEAD POST PUT PATCH DELETE OPTIONS].freeze

    def initialize(config: RailsAutodoc.config)
      @config = config
    end

    def operations
      ensure_controllers_loaded!
      collect_operations.sort_by { |op| [op.path, op.verb, op.action] }
    end

    private

    def ensure_controllers_loaded!
      return unless defined?(Rails) && Rails.application

      Rails.application.eager_load! if Rails.application.config.eager_load == false
    rescue StandardError
      nil
    end

    def collect_operations
      routes.flat_map { |route| operation_from_route(route) }.compact
    end

    def routes
      Rails.application.routes.routes
    end

    def operation_from_route(route)
      return nil unless route.respond_to?(:requirements)

      requirements = route.requirements
      controller_name = requirements[:controller]
      action = requirements[:action]
      return nil if controller_name.blank? || action.blank?

      controller_class = resolve_controller(controller_name)
      return nil unless controller_class
      return nil unless controller_class.action_methods.include?(action.to_s)

      path = normalize_path(route.path.spec.to_s)
      return nil if @config.excluded_path?(path)

      verbs = extract_verbs(route)
      path_params = extract_path_params(path)
      tags = extract_tags(controller_class)

      verbs.map do |verb|
        RouteOperation.new(
          verb: verb,
          path: path,
          controller_class: controller_class,
          action: action,
          route_name: route.name,
          path_params: path_params,
          tags: tags,
          constraints: route.constraints
        )
      end
    rescue StandardError
      nil
    end

    def resolve_controller(controller_name)
      controller_path = "#{controller_name.camelize}Controller"
      controller_path.constantize
    rescue NameError
      nil
    end

    def normalize_path(raw_path)
      path = raw_path
      path = path.sub(/\(\.:format\)\z/, "")
      path = path.sub("(.:format)", "")
      path = "/" if path.blank?
      path
    end

    def extract_verbs(route)
      verb = route.verb
      if verb.is_a?(Regexp)
        HTTP_VERBS.grep(verb)
      elsif verb.is_a?(String)
        verb.split("|").map(&:upcase).reject { |v| v == "HEAD" }
      else
        ["GET"]
      end
    end

    def extract_path_params(path)
      path.scan(/:([a-zA-Z_][a-zA-Z0-9_]*)/).flatten.uniq
    end

    def extract_tags(controller_class)
      parts = controller_class.name.split("::")
      controller_part = parts.last.sub(/Controller\z/, "")
      tags = [controller_part]

      namespace_parts = parts[0..-2]
      tags.concat(namespace_parts) unless namespace_parts.empty?
      tags.uniq
    end
  end
end
