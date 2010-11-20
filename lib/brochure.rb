require "hike"
require "rack"
require "tilt"

module Brochure
  VERSION = "0.5.1"

  autoload :Application,         "brochure/application"
  autoload :CaptureNotSupported, "brochure/errors"
  autoload :Context,             "brochure/context"
  autoload :Failsafe,            "brochure/failsafe"
  autoload :Static,              "brochure/static"
  autoload :Template,            "brochure/template"
  autoload :TemplateNotFound,    "brochure/errors"

  def self.app(root, options = {})
    app = Application.new(root, options)
    app = Static.new(app, app.asset_root)

    if development?
      app = Rack::ShowExceptions.new(app)
    else
      app = Failsafe.new(app)
    end

    app
  end

  def self.development?
    ENV["RACK_ENV"] == "development"
  end
end
