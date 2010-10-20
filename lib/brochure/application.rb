module Brochure
  class Application
    attr_reader :app_root, :template_root, :asset_root

    def initialize(root, options = {})
      @app_root      = File.expand_path(root)
      @template_root = File.join(@app_root, "app", "templates")
      @asset_root    = File.join(@app_root, "public")

      helpers.push(*options[:helpers]) if options[:helpers]
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

    def call(env)
      if forbidden?(env["PATH_INFO"])
        forbidden
      elsif template = find_template(env["PATH_INFO"][/[^.]+/])
        success render_template(template, env)
      else
        not_found
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

    def find_partial(logical_path)
      if template_path = find_partial_path(logical_path)
        template_for(template_path)
      end
    end

    def find_template_path(logical_path)
      candidates = [logical_path + ".html", logical_path + "/index.html"]
      template_trail.find(*candidates)
    end

    def find_partial_path(logical_path)
      path_parts   = logical_path.split("/")
      partial_path = (path_parts[0..-2] + ["_" + path_parts[-1]]).join("/")
      template_trail.find(partial_path + ".html")
    end

    def template_for(template_path)
      if Brochure.development?
        Tilt.new(template_path)
      else
        templates[template_path] ||= Tilt.new(template_path)
      end
    end

    def render_template(template, env, locals = {})
      context = context_class.new(self, env)
      template.render(context, locals)
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
  end
end
