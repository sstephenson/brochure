module Brochure
  class Template
    attr_reader :app, :path

    def initialize(app, path)
      @app  = app
      @path = path
    end

    def template
      @template ||= Tilt.new(path)
    end

    def engine_extension
      @engine_extension ||= File.extname(path)
    end

    def format_extension
      @format_extension ||= begin
        ext = File.extname(File.basename(path, engine_extension))
        ext.empty? ? ".html" : ext
      end
    end

    def content_type
      @content_type ||= begin
        type = Rack::Mime.mime_type(format_extension)
        type[/^text/] ? "#{type}; charset=utf-8" : type
      end
    end

    def render(env, locals = {})
      template.render(app.context_for(self, env), locals)
    end
  end
end
