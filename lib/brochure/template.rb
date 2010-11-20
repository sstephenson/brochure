module Brochure
  class Template
    attr_reader :app, :path

    def initialize(app, path)
      @app  = app
      @path = path
    end

    def template
      @template ||= Tilt.new(path, nil, :outvar => '@_out_buf') if engine_extension
    end

    def basename
      @basename ||= File.basename(path)
    end

    def extensions
      @extensions ||= basename.scan(/\.[^.]+/)
    end

    def format_extension
      extensions.first
    end

    def engine_extension
      extensions[1]
    end

    def content_type
      @content_type ||= begin
        type = Rack::Mime.mime_type(format_extension)
        type[/^text/] ? "#{type}; charset=utf-8" : type
      end
    end

    def render(env, locals = {}, &block)
      if template
        template.render(app.context_for(self, env), locals, &block)
      else
        File.read(path)
      end
    end
  end
end
