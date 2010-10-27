module Brochure
  class Application
    attr_reader :app_root, :template_root, :asset_root, :plugin_root, :assigns

    def initialize(root, options = {})
      @app_root      = File.expand_path(root)
      @template_root = File.join(@app_root, "templates")
      @asset_root    = File.join(@app_root, "public")
      @plugin_root   = File.join(@app_root, "vendor", "plugins")

      @assigns = options[:assigns] || {}
      helpers.push(*options[:helpers]) if options[:helpers]
      initialize_plugins
    end

    def initialize_plugins
      plugins.each do |plugin_root|
        template_trail.paths.push(File.join(plugin_root, "templates"))
      end
    end

    def template_trail
      @template_trail ||= Hike::Trail.new(app_root).tap do |trail|
        trail.extensions.replace(Tilt.mappings.keys.sort)
        trail.paths.push(template_root)
      end
    end

    def context_class
      @context_class ||= Context.for(helpers)
    end

    def templates
      @templates ||= {}
    end

    def helpers
      @helpers ||= []
    end

    def plugins
      @plugins ||= Dir[File.join(plugin_root, "*")].select do |entry|
        File.directory?(entry)
      end
    end

    def call(env)
      if forbidden?(env["PATH_INFO"])
        forbidden
      elsif template = find_template(env["PATH_INFO"][/[^.]+/])
        success render_template(template, env)
      else
        not_found(env)
      end
    end

    def forbidden?(path)
      path[".."] || File.basename(path)[/^_/]
    end

    def find_template(logical_path)
      if template_path = find_template_path(logical_path)
        template_for(template_path)
      end
    end

    def find_partial(logical_path, format_extension)
      if template_path = find_partial_path(logical_path, format_extension)
        template_for(template_path)
      end
    end

    def find_template_path(logical_path)
      candidates = [logical_path + ".html", logical_path + "/index.html"]
      template_trail.find(*candidates)
    end

    def find_partial_path(logical_path, format_extension)
      dirname, basename = File.split(logical_path)
      partial_path = File.join(dirname, "_" + basename + format_extension)
      template_trail.find(partial_path)
    end

    def template_for(template_path)
      templates[template_path] ||= Template.new(self, template_path)
    end

    def context_for(template, env)
      context_class.new(self, template, env, assigns)
    end

    def render_template(template, env, locals = {})
      template.render(env, locals)
    end

    def respond_with(status, body, content_type = "text/html; charset=utf-8")
      headers = {
        "Content-Type"   => content_type,
        "Content-Length" => Rack::Utils.bytesize(body).to_s
      }
      [status, headers, [body]]
    end

    def success(body)
      respond_with 200, body
    end

    def not_found(env)
      if template = find_template("404")
        respond_with 404, render_template(template, env)
      else
        default_not_found
      end
    end

    def default_not_found
      respond_with 404, <<-HTML
        <!DOCTYPE html>
        <html><head><title>Not Found</title></head>
        <body><h1>404 Not Found</h1></body></html>
      HTML
    end

    def forbidden
      respond_with 403, "Forbidden"
    end
  end
end
