module Brochure
  class Context
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

    def render(logical_path, locals = {}, &block)
      if partial = application.find_partial(logical_path, template.format_extension)
        if block_given?
          concat partial.render(env, locals) { capture(&block) }
        else
          partial.render(env, locals)
        end
      else
        raise TemplateNotFound, "no such template '#{logical_path}'"
      end
    end

    def engine_name
      template.engine_extension[1..-1]
    end

    def concat(str)
      if respond_to?(method = "#{engine_name}_concat")
        send(method, str)
      elsif @_out_buf
        @_out_buf << str
      else
        raise CaptureNotSupported, "no capture support for #{engine_name} templates"
      end
    end

    def capture(&block)
      if respond_to?(method = "capture_#{engine_name}")
        send(method, &block)
      elsif @_out_buf
        begin
          buf = ""
          old_buf, @_out_buf = @_out_buf, buf
          yield
          buf
        ensure
          @_out_buf = old_buf
        end
      else
        raise CaptureNotSupported, "no capture support for #{engine_name} templates"
      end
    end
  end
end
