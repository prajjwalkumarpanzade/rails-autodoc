# frozen_string_literal: true

require "parser/current"

module RailsAutodoc
  class StrongParamsParser
    include AstTraversal

    ParamsResult = Struct.new(:root_key, :schema, :method_name, keyword_init: true)

    def initialize(source_path:, class_name:)
      @source_path = source_path
      @class_name = class_name
      @buffer, = Parser::CurrentRuby.parse_file(source_path)
    end

    def param_methods
      methods = {}
      each_method_definition(class_node) do |child|
        method_name = method_name_for(child)
        next unless method_name.end_with?("_params")

        schema = extract_permit_schema(child)
        next if schema.nil?

        methods[method_name] = ParamsResult.new(
          root_key: schema[:root_key],
          schema: schema[:properties],
          method_name: method_name
        )
      end
      methods
    end

    def params_for_action(action_name)
      action_node = find_action_node(action_name)
      return nil unless action_node

      called_methods = extract_called_param_methods(action_node)
      called_methods.each do |method_name|
        result = param_methods[method_name]
        return result if result
      end

      param_methods.values.first
    end

    def query_params_for_action(action_name)
      action_node = find_action_node(action_name)
      return [] unless action_node

      params = []
      walk_nodes(action_node) do |node|
        next unless node.type == :send

        method_name = node.children[1]
        case method_name
        when :[]
          param_name = literal_value(node.children[2])
          if param_name && node.children[0]&.type == :send && node.children[0].children[1] == :params
            params << param_name.to_s
          end
        when :fetch
          param_name = literal_value(node.children[2])
          if param_name && node.children[0]&.type == :send && node.children[0].children[1] == :params
            params << param_name.to_s
          end
        end
      end

      params.uniq.map do |name|
        { name: name, type: "string", required: false }
      end
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

    def extract_called_param_methods(action_node)
      methods = []
      walk_nodes(action_node) do |node|
        next unless node.type == :send

        method_name = node.children[1]
        methods << method_name.to_s if method_name.to_s.end_with?("_params")
      end
      methods.uniq
    end

    def extract_permit_schema(method_node)
      root_key = nil
      properties = nil

      walk_nodes(method_node) do |node|
        next unless node.type == :send

        method_name = node.children[1]
        if method_name == :require
          root_key = literal_value(node.children[2])
        elsif method_name == :permit
          properties = parse_permit_args(node.children[2..])
        end
      end

      return nil unless properties

      { root_key: root_key, properties: properties }
    end

    def parse_permit_args(args)
      schema = { type: "object", properties: {}, required: [] }

      args.each do |arg|
        case arg.type
        when :sym
          field = arg.children[0].to_s
          schema[:properties][field] = { type: "string" }
          schema[:required] << field
        when :hash
          each_hash_pair(arg) do |key_node, value_node|
            field = literal_value(key_node).to_s
            schema[:properties][field] = parse_nested_permit_value(value_node)
            schema[:required] << field
          end
        end
      end

      schema[:required].uniq!
      schema
    end

    def each_hash_pair(hash_node, &block)
      hash_node.children.each do |pair_node|
        next unless pair_node.type == :pair

        yield pair_node.children[0], pair_node.children[1]
      end
    end

    def parse_nested_permit_value(node)
      case node.type
      when :array
        symbols = node.children.compact.select { |child| child.type == :sym }
        if symbols.any?
          properties = symbols.to_h do |sym|
            [sym.children[0].to_s, { type: "string" }]
          end
          return {
            type: "object",
            properties: properties,
            required: properties.keys
          }
        end

        inner = node.children[0]
        if inner&.type == :hash
          parse_permit_args([inner])
        else
          { type: "array", items: { type: "string" } }
        end
      when :hash
        parse_permit_args([node])
      else
        { type: "string" }
      end
    end

    def literal_value(node)
      case node&.type
      when :sym then node.children[0]
      when :str then node.children[0]
      else node.to_s
      end
    end
  end
end
