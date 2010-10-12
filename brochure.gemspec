spec = Gem::Specification.new do |s|
  s.name         = "brochure"
  s.version      = "0.1.0"
  s.platform     = Gem::Platform::RUBY
  s.authors      = ["Sam Stephenson"]
  s.email        = ["sstephenson@gmail.com"]
  s.homepage     = "http://github.com/sstephenson/brochure"
  s.summary      = "Rack + ERB static sites"
  s.description  = "A Rack application for serving static sites with ERB templates."
  s.files        = ["lib/brochure.rb", "README.md", "LICENSE"]
  s.require_path = "lib"

  s.add_development_dependency "rack-test"
end

