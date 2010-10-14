module Brochure
  class Failsafe
    def initialize(app)
      @app = app
    end

    def call(env)
      @app.call(env)
    rescue Exception => exception
      backtrace = ["#{exception.class.name}: #{exception}", *exception.backtrace].join("\n  ")
      env["rack.errors"].puts(backtrace)
      env["rack.errors"].flush

      body = <<-HTML
        <!DOCTYPE html>
        <html><head><title>Internal Server Error</title></head>
        <body><h1>500 Internal Server Error</h1></body></html>
      HTML

      [500,
       { "Content-Type"   => "text/html, charset=utf-8",
         "Content-Length" => Rack::Utils.bytesize(body).to_s },
       [body]]
    end
  end
end
