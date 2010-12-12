module Brochure
  class Application
    attr_reader :app_root, :template_root, :asset_root, :plugin_root, :assigns, :template_options

    def initialize(root, options = {})
      @app_root      = File.expand_path(root)
      @template_root = File.join(@app_root, "templates")
      @asset_root    = File.join(@app_root, "public")
      @plugin_root   = File.join(@app_root, "vendor", "plugins")

      @assigns = options[:assigns] || {}
      @template_options = options[:template_options] || {}
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
      elsif template = find_template(env["PATH_INFO"])
        success template.render(env), template.content_type
      else
        not_found(env)
      end
    end

    def forbidden?(path)
      path[".."] || File.basename(path)[/^_/]
    end

    def find_template(logical_path, format_extension = ".html")
      if template_path = find_template_path(logical_path, format_extension)
        template_for(template_path)
      end
    end

    def find_partial(logical_path, format_extension = ".html")
      if template_path = find_partial_path(logical_path, format_extension)
        template_for(template_path)
      end
    end

    def find_template_path(logical_path, format_extension)
	  if logical_path == '/'
	    template_trail.find("/index" + format_extension)
	  else
        template_trail.find(logical_path, logical_path + format_extension, logical_path + "/index" + format_extension)
	  end
    end

    def find_partial_path(logical_path, format_extension)
      dirname, basename = File.split(logical_path)
      if dirname == "."
        partial_path = "_" + basename
      else
        partial_path = File.join(dirname, "_" + basename)
      end
      template_trail.find(partial_path, partial_path + format_extension)
    end

    def template_for(template_path)
      if Brochure.development?
        Template.new(self, template_path)
      else
        templates[template_path] ||= Template.new(self, template_path)
      end
    end

    def context_for(template, env)
      context_class.new(self, template, env, assigns)
    end

    def respond_with(status, body, content_type = "text/html; charset=utf-8")
      headers = {
        "Content-Type"   => content_type,
        "Content-Length" => Rack::Utils.bytesize(body).to_s
      }
      [status, headers, [body]]
    end

    def success(body, content_type)
      respond_with 200, body, content_type
    end

    def not_found(env)
      if template = find_template("404")
        respond_with 404, template.render(env)
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
