require "tilt"

module Brochure
  class Application
    def initialize(root)
      @app_root      = File.expand_path(root)
      @helper_root   = File.join(@app_root, "app", "helpers")
      @template_root = File.join(@app_root, "app", "templates")
      @context_class = Context.for(helpers)
      @templates     = {}
    end

    def helpers
      @helpers ||= Dir[File.join(@helper_root, "**", "*.rb")].map do |helper_path|
        base_name    = helper_path[(@helper_root.length + 1)..-1][/(.*?)\.rb$/, 1]
        module_names = base_name.split("/").map { |n| Brochure.camelize(n) }
        load helper_path
        module_names.inject(Kernel) { |mod, name| mod.const_get(name) }
      end
    end

    def call(env)
      if env["PATH_INFO"].include?("..")
        forbidden
      else
        logical_path = env["PATH_INFO"][/[^.]+/]
        success render(logical_path)
      end
    rescue TemplateNotFound => e
      not_found
    rescue StandardError => e
      error e
    end

    def find_template_path(logical_path, options = {})
      if options[:partial]
        path_parts   = logical_path.split("/")
        logical_path = (path_parts[0..-2] + ["_" + path_parts[-1]]).join("/")
      else
        return false if File.basename(logical_path)[/^_/]
      end

      template_path = if File.directory?(File.join(@template_root, logical_path))
        File.join(@template_root, logical_path, "index.html.erb")
      else
        File.join(@template_root, logical_path + ".html.erb")
      end

      File.exists?(template_path) && template_path
    end

    def render(logical_path, options = {})
      if template_path = find_template_path(logical_path, options)
        context = @context_class.new(self)
        locals  = options[:locals] || {}
        template_for(template_path).render(context, locals)
      else
        raise TemplateNotFound, "no such template '#{logical_path}'"
      end
    end

    def template_for(template_path)
      @templates[template_path] ||= Tilt.new(template_path)
    end

    def respond_with(status, body, content_type = "text/html, charset=utf-8")
      headers = {
        "Content-Type"   => content_type,
        "Content-Length" => body.length.to_s
      }
      [status, headers, [body]]
    end

    def success(body)
      respond_with 200, body
    end

    def not_found
      respond_with 404, <<-HTML
        <!DOCTYPE html>
        <html><head><title>Not Found</title></head>
        <body><h1>404 Not Found</h1></body></html>
      HTML
    end

    def forbidden
      respond_with 403, "Forbidden"
    end

    def error(exception)
      warn ["#{exception.class.name}: #{exception}", *exception.backtrace].join("\n  ")
      respond_with 500, <<-HTML
        <!DOCTYPE html>
        <html><head><title>Internal Server Error</title></head>
        <body><h1>500 Internal Server Error</h1></body></html>
      HTML
    end
  end

  class Context
    include Tilt::CompileSite

    def self.for(helpers)
      context = Class.new(self)
      context.send(:include, *helpers) if helpers.any?
      context
    end

    def initialize(application)
      @application = application
    end

    def render(logical_path, locals = {})
      @application.render(logical_path, :partial => true, :locals => locals)
    end
  end

  class TemplateNotFound < StandardError; end

  def self.camelize(string)
    string.gsub(/(^|_)(\w)/) { $2.upcase }
  end
end
