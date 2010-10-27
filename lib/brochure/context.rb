module Brochure
  class Context
    include Tilt::CompileSite

    def self.for(helpers)
      context = Class.new(self)
      context.send(:include, *helpers) if helpers.any?
      context
    end

    attr_reader :application, :template, :env

    def initialize(application, template, env, assigns = {})
      @application = application
      @template = template
      @env = env

      load_assigns(assigns)
    end

    def load_assigns(assigns)
      assigns.each do |name, value|
        instance_variable_set("@#{name}", value)
      end
    end

    def request
      @request ||= Rack::Request.new(env)
    end

    def h(html)
      Rack::Utils.escape_html(html)
    end

    def render(logical_path, locals = {})
      if partial = application.find_partial(logical_path, template.format_extension)
        partial.render(env, locals)
      else
        raise TemplateNotFound, "no such template '#{logical_path}'"
      end
    end
  end
end
