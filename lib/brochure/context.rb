module Brochure
  class Context
    include Tilt::CompileSite

    def self.for(helpers)
      context = Class.new(self)
      context.send(:include, *helpers) if helpers.any?
      context
    end

    attr_accessor :application, :env

    def initialize(application, env)
      self.application = application
      self.env = env
    end

    def request
      @_request ||= Rack::Request.new(env)
    end

    def render(logical_path, locals = {})
      if template = @application.find_template(logical_path, true)
        @application.render_template(template, env, locals)
      else
        raise TemplateNotFound, "no such template '#{logical_path}'"
      end
    end
  end
end
