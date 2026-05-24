# frozen_string_literal: true

namespace :autodoc do
  desc "Generate OpenAPI specification from Rails routes and controllers"
  task generate: :environment do
    spec = RailsAutodoc::Generator.new.generate!
    path = RailsAutodoc.config.resolved_output_path
    puts "Generated OpenAPI spec at #{path}"
    puts "Operations: #{spec.fetch('paths', {}).values.flat_map(&:keys).size}"
  end

  desc "Verify OpenAPI specification is up to date"
  task verify: :environment do
    RailsAutodoc::Generator.new.verify!
    puts "OpenAPI spec is up to date."
  end

  desc "List inferred API operations"
  task routes: :environment do
    operations = RailsAutodoc::RouteInspector.new.operations
    operations.each do |operation|
      puts "#{operation.verb.ljust(7)} #{operation.openapi_path.ljust(40)} #{operation.controller_class.name}##{operation.action}"
    end
    puts "\nTotal: #{operations.size} operations"
  end
end
