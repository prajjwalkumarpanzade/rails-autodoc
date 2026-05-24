# frozen_string_literal: true

module RailsAutodoc
  module AstTraversal
    private

    def walk_nodes(node, &block)
      yield node

      node.children.compact.each do |child|
        walk_nodes(child, &block) if child.is_a?(Parser::AST::Node)
      end
    end

    def each_method_definition(class_node, &block)
      return unless class_node

      walk_nodes(class_node) do |node|
        yield node if method_definition?(node)
      end
    end

    def method_definition?(node)
      %i[def defs].include?(node.type)
    end

    def method_name_for(node)
      case node.type
      when :def then node.children[0].to_s
      when :defs then node.children[1].to_s
      end
    end

    def find_class_node(node, class_name: nil)
      return nil unless node

      if node.type == :class && (class_name.nil? || class_name_matches?(node, class_name))
        node
      else
        node.children.compact.each do |child|
          next unless child.is_a?(Parser::AST::Node)

          found = find_class_node(child, class_name: class_name)
          return found if found
        end
        nil
      end
    end

    def class_name_matches?(node, class_name)
      const_node = node.children[0]
      return false unless const_node

      full_name = const_path(const_node)
      simple_name = class_name.split("::").last

      full_name == class_name ||
        full_name == simple_name ||
        class_name.end_with?("::#{full_name}") ||
        full_name.end_with?("::#{simple_name}")
    end

    def const_path(node)
      case node.type
      when :const
        parent = node.children[0]
        name = node.children[1].to_s
        parent ? "#{const_path(parent)}::#{name}" : name
      else
        ""
      end
    end
  end
end
