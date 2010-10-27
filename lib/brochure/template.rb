module Brochure
  class Template
    attr_reader :app, :path

    def initialize(app, path)
      @app  = app
      @path = path
    end

    def template
      if Brochure.development?
        Tilt.new(path)
      else
        @template ||= Tilt.new(path)
      end
    end

    def render(env, locals = {})
      template.render(app.context_for(self, env), locals)
    end

    def engine_extension
      File.extname(path)
    end

    def format_extension
      ext = File.extname(File.basename(path, engine_extension))
      ext.empty? ? ".html" : ext
    end
  end
end
