# frozen_string_literal: true

module RailsAutodoc
  class SpecController < ActionController::Base
    def show
      spec = cached_spec
      render json: spec
    end

    def ui
      render html: swagger_ui_html.html_safe
    end

    private

    def cached_spec
      return self.class.cached_spec if RailsAutodoc.config.cache_spec_in_dev && self.class.cached_spec

      self.class.cached_spec = Generator.new.generate
    end

    def swagger_ui_html
      spec_url = "#{RailsAutodoc.config.mount_path}/spec.json"
      <<~HTML
        <!DOCTYPE html>
        <html lang="en">
          <head>
            <meta charset="UTF-8" />
            <title>#{RailsAutodoc.config.title} API Docs</title>
            <link rel="stylesheet" href="https://unpkg.com/swagger-ui-dist@5/swagger-ui.css" />
          </head>
          <body>
            <div id="swagger-ui"></div>
            <script src="https://unpkg.com/swagger-ui-dist@5/swagger-ui-bundle.js"></script>
            <script>
              window.onload = function() {
                SwaggerUIBundle({
                  url: "#{spec_url}",
                  dom_id: "#swagger-ui"
                });
              };
            </script>
          </body>
        </html>
      HTML
    end

    class << self
      attr_accessor :cached_spec
    end
  end
end
