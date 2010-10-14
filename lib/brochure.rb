require "rack"
require "tilt"

module Brochure
  autoload :Application,      "brochure/application"
  autoload :Context,          "brochure/context"
  autoload :Failsafe,         "brochure/failsafe"
  autoload :TemplateNotFound, "brochure/errors"

  def self.app(root)
    app = Application.new(root)
    if development?
      app = Rack::ShowExceptions.new(app)
    else
      app = Failsafe.new(app)
    end
    app
  end

  def self.camelize(string)
    string.gsub(/(^|_)(\w)/) { $2.upcase }
  end

  def self.development?
    ENV["RACK_ENV"] == "development"
  end
end
