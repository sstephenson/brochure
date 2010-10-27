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
      template.render(app.context_for(env), locals)
    end
  end
end
