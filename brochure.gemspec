spec = Gem::Specification.new do |s|
  s.name         = "brochure"
  s.version      = "0.5.3"
  s.platform     = Gem::Platform::RUBY
  s.authors      = ["Sam Stephenson", "Josh Peek"]
  s.email        = ["sstephenson@gmail.com", "josh@joshpeek.com"]
  s.homepage     = "http://github.com/sstephenson/brochure"
  s.summary      = "Rack + ERB static sites"
  s.description  = "A Rack application for serving static sites with ERB templates."
  s.files        = Dir["lib/**/*.rb", "README.md", "LICENSE"]
  s.require_path = "lib"

  s.add_dependency "hike", "~> 1.0"
  s.add_dependency "rack", "~> 1.0"
  s.add_dependency "tilt", ">= 1.1.0"

  s.add_development_dependency "rack-test"
  s.add_development_dependency "haml"
end

