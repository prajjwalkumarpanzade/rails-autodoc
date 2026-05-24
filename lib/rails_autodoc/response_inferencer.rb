# frozen_string_literal: true

require "parser/current"

module RailsAutodoc
  class ResponseInferencer
    include AstTraversal

    ResponseHint = Struct.new(:status, :schema_ref, :schema, :description, keyword_init: true)

    DEFAULT_STATUS = {
      "GET" => "200",
      "POST" => "201",
      "PUT" => "200",
      "PATCH" => "200",
      "DELETE" => "204"
    }.freeze

    def initialize(source_path:, class_name:, serializer_registry: Serializers::Registry.new)
      @source_path = source_path
      @class_name = class_name
      @serializer_registry = serializer_registry
      @buffer, = Parser::CurrentRuby.parse_file(source_path)
    end

    def responses_for_action(action_name, verb: "GET")
      action_node = find_action_node(action_name)
      hints = action_node ? extract_render_hints(action_node) : []

      hints << default_response(verb) if hints.empty?

      hints
    end

    private

    def class_node
      @class_node ||= find_class_node(@buffer, class_name: @class_name)
    end

    def find_action_node(action_name)
      each_method_definition(class_node) do |child|
        next unless child.type == :def

        return child if child.children[0].to_s == action_name.to_s
      end
      nil
    end

    def extract_render_hints(action_node)
      hints = []
      walk_nodes(action_node) do |node|
        next unless node.type == :send

        if node.children[1] == :render
          hint = build_hint_from_render(node)
          hints << hint if hint
        elsif node.children[1] == :head
          status = normalize_status(node.children[2])
          hints << ResponseHint.new(status: status, schema: nil, description: "No content")
        end
      end
      hints
    end

    def build_hint_from_render(node)
      status = "200"
      schema_ref = nil
      schema = { type: "object" }

      node.children[2..].each do |arg|
        next unless arg

        next unless arg.type == :hash

        each_hash_pair(arg) do |key, value|
          case literal_value(key)
          when :json
            schema_ref, schema = infer_json_schema(value)
          when :status
            status = normalize_status(value)
          end
        end
      end

      ResponseHint.new(status: status, schema_ref: schema_ref, schema: schema, description: "Successful response")
    end

    def infer_json_schema(value_node)
      case value_node.type
      when :send
        receiver = value_node.children[0]
        method_name = value_node.children[1]
        if receiver&.type == :const && method_name == :new
          serializer_class = const_path(receiver)
          schema = @serializer_registry.schema_for(serializer_class)
          return [serializer_class, schema]
        end
        if receiver&.type == :ivar
          model_name = infer_model_from_ivar(receiver)
          return [model_name, { "$ref" => "#/components/schemas/#{model_name}" }] if model_name
        end
      when :const
        model_name = const_path(value_node)
        return [model_name, { "$ref" => "#/components/schemas/#{model_name}" }]
      when :hash
        return [nil, { type: "object" }]
      end

      [nil, { type: "object" }]
    end

    def infer_model_from_ivar(node)
      node.children[0].to_s.sub(/^@/, "").classify
    rescue StandardError
      nil
    end

    def each_hash_pair(hash_node, &block)
      hash_node.children.each do |pair_node|
        next unless pair_node.type == :pair

        yield pair_node.children[0], pair_node.children[1]
      end
    end

    def default_response(verb)
      status = DEFAULT_STATUS.fetch(verb, "200")
      if status == "204"
        ResponseHint.new(status: status, schema: nil, description: "No content")
      else
        ResponseHint.new(status: status, schema: { type: "object" }, description: "Successful response")
      end
    end

    def normalize_status(node)
      value = literal_value(node)
      case value
      when Integer then value.to_s
      when Symbol
        Rack::Utils.status_code(value).to_s
      else
        value.to_s
      end
    rescue StandardError
      "200"
    end

    def literal_value(node)
      case node&.type
      when :sym then node.children[0]
      when :int then node.children[0]
      when :str then node.children[0]
      else node.to_s
      end
    end
  end
end
