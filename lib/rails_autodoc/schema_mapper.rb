# frozen_string_literal: true

module RailsAutodoc
  class SchemaMapper
    TYPE_MAP = {
      string: { type: "string" },
      text: { type: "string" },
      citext: { type: "string" },
      uuid: { type: "string", format: "uuid" },
      integer: { type: "integer" },
      bigint: { type: "integer", format: "int64" },
      float: { type: "number", format: "float" },
      decimal: { type: "number", format: "double" },
      boolean: { type: "boolean" },
      datetime: { type: "string", format: "date-time" },
      date: { type: "string", format: "date" },
      time: { type: "string", format: "time" },
      json: { type: "object" },
      jsonb: { type: "object" }
    }.freeze

    def initialize(schema_path: default_schema_path)
      @schema_path = schema_path
      @tables = {}
      @models = {}
      load_schema if @schema_path&.exist?
    end

    def apply_types!(schema, model_name: nil)
      return schema unless schema.is_a?(Hash)

      schema[:properties]&.each do |field, field_schema|
        typed = column_schema(model_name, field) if model_name
        schema[:properties][field] = merge_schemas(field_schema, typed) if typed
        apply_types!(schema[:properties][field], model_name: model_name)
      end

      schema
    end

    def model_schema(model_name)
      return nil unless defined?(ActiveRecord::Base)

      model = model_name.constantize
      table = model.table_name
      columns = @tables[table]
      return nil unless columns

      properties = {}
      required = []
      columns.each do |column_name, column_meta|
        next if %w[id created_at updated_at].include?(column_name)

        properties[column_name] = column_meta.dup
        required << column_name unless column_meta[:nullable]
      end

      {
        type: "object",
        properties: properties,
        required: required
      }
    rescue StandardError
      nil
    end

    def infer_model_from_controller(controller_class)
      name = controller_class.name.split("::").last.sub(/Controller\z/, "").singularize
      name.constantize.name
    rescue StandardError
      nil
    end

    def all_model_schemas
      return {} unless defined?(ActiveRecord::Base)

      schemas = {}
      @tables.each_key do |table|
        model_name = table.classify
        schema = model_schema(model_name)
        schemas[model_name] = schema if schema
      rescue StandardError
        next
      end
      schemas
    end

    private

    def default_schema_path
      return nil unless defined?(Rails) && Rails.respond_to?(:root)

      Rails.root.join("db/schema.rb")
    end

    def load_schema
      content = @schema_path.read.gsub("\r\n", "\n")
      parse_create_tables(content)
    end

    def parse_create_tables(content)
      content.scan(/create_table\s+"([^"]+)"[^\n]*\n(.*?)end/m).each do |table, body|
        @tables[table] = parse_columns(body)
      end
    end

    def parse_columns(body)
      columns = {}
      body.scan(/t\.(\w+)\s+"([^"]+)"(?:,\s*(.*?))?(?:\r)?$/).each do |type, name, options|
        columns[name] = build_column_schema(type, options)
      end
      columns
    end

    def build_column_schema(type, options)
      schema = (TYPE_MAP[type.to_sym] || { type: "string" }).dup
      schema[:nullable] = options.to_s.include?("null: false") == false
      schema
    end

    def column_schema(model_name, field)
      return nil unless model_name

      model = model_name.constantize
      table = model.table_name
      column = @tables.dig(table, field.to_s)
      return nil unless column

      column.dup.tap { |s| s.delete(:nullable) }
    rescue StandardError
      nil
    end

    def merge_schemas(base, overlay)
      return overlay unless base.is_a?(Hash)

      base.merge(overlay) do |_key, old_val, new_val|
        old_val.is_a?(Hash) && new_val.is_a?(Hash) ? old_val.merge(new_val) : new_val
      end
    end
  end
end
