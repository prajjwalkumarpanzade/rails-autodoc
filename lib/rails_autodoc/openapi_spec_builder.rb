# frozen_string_literal: true

module RailsAutodoc
  class OpenapiSpecBuilder
    def initialize(
      operations:,
      config: RailsAutodoc.config,
      registry: RailsAutodoc.registry,
      schema_mapper: SchemaMapper.new
    )
      @operations = operations
      @config = config
      @registry = registry
      @schema_mapper = schema_mapper
    end

    def build
      {
        "openapi" => "3.0.3",
        "info" => info_block,
        "servers" => servers_block,
        "tags" => tags_block,
        "paths" => paths_block,
        "components" => components_block
      }.compact
    end

    private

    def info_block
      {
        "title" => @config.title,
        "version" => @config.version,
        "description" => @config.description
      }.compact
    end

    def servers_block
      return @config.servers if @config.servers.any?

      if defined?(Rails) && Rails.application.routes.default_url_options[:host]
        host = Rails.application.routes.default_url_options[:host]
        [{ "url" => "https://#{host}" }]
      else
        [{ "url" => "http://localhost:3000" }]
      end
    end

    def tags_block
      @operations.flat_map(&:tags).uniq.sort.map { |tag| { "name" => tag } }
    end

    def paths_block
      paths = {}

      @operations.each do |operation|
        annotation = @registry.find(operation.controller_class, operation.action)
        next if annotation&.exclude

        path_key = operation.openapi_path
        paths[path_key] ||= {}
        paths[path_key][operation.verb.downcase] = build_operation(operation, annotation)
      end

      paths
    end

    def build_operation(operation, annotation)
      model_name = @schema_mapper.infer_model_from_controller(operation.controller_class)
      request_body = build_request_body(operation, annotation, model_name)
      responses = build_responses(operation, annotation, model_name)

      operation_hash = {
        "operationId" => annotation&.operation_id || operation.operation_id,
        "tags" => merged_tags(operation, annotation),
        "summary" => annotation&.summary || "#{operation.verb} #{operation.openapi_path}",
        "description" => annotation&.description,
        "deprecated" => annotation&.deprecated || false,
        "parameters" => build_parameters(operation, annotation),
        "responses" => responses
      }

      operation_hash["requestBody"] = request_body if request_body
      operation_hash["security"] = build_security(annotation) if annotation&.security || @config.default_security
      operation_hash.compact
    end

    def merged_tags(operation, annotation)
      tags = operation.tags.dup
      tags.concat(annotation.tags) if annotation&.tags&.any?
      tags.uniq
    end

    def build_parameters(operation, annotation)
      params = operation.path_params.map do |name|
        {
          "name" => name,
          "in" => "path",
          "required" => true,
          "schema" => { "type" => "string" }
        }
      end

      annotation&.query_params&.each do |query_param|
        params << {
          "name" => query_param[:name],
          "in" => "query",
          "required" => query_param.fetch(:required, false),
          "schema" => query_schema(query_param)
        }
      end

      inferred_query_params(operation).each do |query_param|
        next if params.any? { |entry| entry["name"] == query_param[:name] }

        params << {
          "name" => query_param[:name],
          "in" => "query",
          "required" => query_param.fetch(:required, false),
          "schema" => query_schema(query_param)
        }
      end

      params
    end

    def inferred_query_params(operation)
      source_path = controller_source_path(operation.controller_class)
      return [] unless source_path&.exist?

      StrongParamsParser.new(
        source_path: source_path,
        class_name: operation.controller_class.name
      ).query_params_for_action(operation.action)
    rescue StandardError
      []
    end

    def query_schema(query_param)
      schema = { "type" => query_param[:type] || "string" }
      schema["enum"] = query_param[:enum] if query_param[:enum]
      schema
    end

    def build_request_body(operation, annotation, model_name)
      if annotation&.request_body_schema
        return {
          "required" => true,
          "content" => {
            "application/json" => {
              "schema" => annotation.request_body_schema
            }
          }
        }
      end

      schema = infer_request_schema(operation, model_name)

      schema = { type: "object", properties: {}, required: [] } if schema.nil? && annotation&.body_params&.any?

      return nil unless schema

      if annotation&.body_params&.any?
        schema[:properties] ||= {}
        schema[:required] ||= []

        annotation.body_params.each do |param|
          schema[:properties][param[:name]] = {
            "type" => param[:type]
          }.tap do |entry|
            entry["enum"] = param[:enum] if param[:enum]
          end
          schema[:required] << param[:name] unless schema[:required].include?(param[:name])
        end
      end

      {
        "required" => true,
        "content" => {
          "application/json" => {
            "schema" => deep_stringify(schema)
          }
        }
      }
    end

    def infer_request_schema(operation, model_name)
      source_path = controller_source_path(operation.controller_class)
      return nil unless source_path&.exist?

      parser = StrongParamsParser.new(
        source_path: source_path,
        class_name: operation.controller_class.name
      )
      params_result = parser.params_for_action(operation.action)
      return nil unless params_result

      schema = params_result.schema.dup
      @schema_mapper.apply_types!(schema, model_name: model_name)

      if params_result.root_key
        {
          type: "object",
          properties: {
            params_result.root_key.to_s => deep_stringify(schema)
          },
          required: [params_result.root_key.to_s]
        }
      else
        schema
      end
    rescue StandardError
      nil
    end

    def build_responses(operation, annotation, model_name)
      if annotation&.responses&.any?
        return annotation.responses.transform_keys(&:to_s).transform_values do |response|
          build_response_entry(response)
        end
      end

      source_path = controller_source_path(operation.controller_class)
      hints = if source_path&.exist?
                ResponseInferencer.new(
                  source_path: source_path,
                  class_name: operation.controller_class.name
                ).responses_for_action(operation.action, verb: operation.verb)
              else
                []
              end

      if hints.empty?
        hints = [ResponseInferencer::ResponseHint.new(status: "200", schema: { type: "object" },
                                                      description: "Successful response")]
      end

      hints.each_with_object({}) do |hint, hash|
        entry = { "description" => hint.description || "Response" }
        if hint.schema
          entry["content"] = {
            "application/json" => {
              "schema" => deep_stringify(hint.schema)
            }
          }
        elsif hint.schema_ref
          entry["content"] = {
            "application/json" => {
              "schema" => { "$ref" => "#/components/schemas/#{hint.schema_ref}" }
            }
          }
        elsif model_name && hint.status != "204"
          entry["content"] = {
            "application/json" => {
              "schema" => { "$ref" => "#/components/schemas/#{model_name}" }
            }
          }
        end
        hash[hint.status] = entry
      end
    end

    def build_response_entry(response)
      entry = { "description" => response[:description] || "Response" }
      if response[:ref]
        entry["content"] = {
          "application/json" => {
            "schema" => { "$ref" => "#/components/schemas/#{response[:ref]}" }
          }
        }
      elsif response[:schema]
        entry["content"] = {
          "application/json" => {
            "schema" => deep_stringify(response[:schema])
          }
        }
      end
      entry
    end

    def build_security(annotation)
      scheme = annotation&.security || @config.default_security
      [{ scheme.to_s => [] }]
    end

    def components_block
      schemas = @schema_mapper.all_model_schemas
      components = {}
      components["schemas"] = schemas.transform_values { |schema| deep_stringify(schema) } if schemas.any?
      components["securitySchemes"] = @config.security_schemes if @config.security_schemes.any?
      components.presence
    end

    def controller_source_path(controller_class)
      conventional_controller_path(controller_class) || existing_source_location_path(controller_class)
    end

    def existing_source_location_path(controller_class)
      path = source_location_path(controller_class)
      path if path&.exist?
    end

    def source_location_path(controller_class)
      return nil unless controller_class.respond_to?(:instance_method)

      Pathname.new(controller_class.instance_method(:initialize).source_location.first)
    rescue StandardError
      nil
    end

    def conventional_controller_path(controller_class)
      return nil unless defined?(Rails) && Rails.respond_to?(:root)

      relative = "#{controller_class.name.underscore}.rb"
      path = Rails.root.join("app/controllers", relative)
      path.exist? ? path : nil
    end

    def deep_stringify(value)
      case value
      when Hash
        value.each_with_object({}) do |(key, val), result|
          result[key.to_s] = deep_stringify(val)
        end
      when Array
        value.map { |item| deep_stringify(item) }
      when Symbol
        value.to_s
      else
        value
      end
    end
  end
end
