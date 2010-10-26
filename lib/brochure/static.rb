require 'rack/file'

module Brochure
  class Static
    def initialize(app, dir)
      @file = Rack::File.new(dir)
      @app = app
    end

    def call(env)
      status, headers, body = @file.call(env)
      if status > 400
        @app.call(env)
      else
        [status, headers, body]
      end
    end
  end
end
