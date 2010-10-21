Brochure
========

A Rack application for serving static sites with ERB templates (or any
of the many [template languages supported by
Tilt](http://github.com/rtomayko/tilt/blob/master/TEMPLATES.md#readme)).

Sample application structure:

    templates/
      help/
        index.html.erb
      index.html.erb
      shared/
        _header.html.erb
        _footer.html.erb
      signup.html.erb
    config.ru
    public/
      ...

Sample `config.ru`:

    require "brochure"
    ROOT = File.dirname(__FILE__)
    run Brochure.app(ROOT)


## Templates and URL mapping

URLs are automatically mapped to template names:

* `/` &rarr; `templates/index.html.erb`
* `/signup` &rarr; `templates/signup.html.erb`
* `/help/` &rarr; `templates/help/index.html.erb`

Templates can render partials. A partial is denoted by a leading
underscore in its filename. So `<%= render "shared/header" %>` will
render `templates/shared/_header.html.erb` inline.

Templates have access to the Rack environment via the `env` method and
to the Brochure application via the `application` method.


## Helper methods and instance variables

You can make additional helper methods and instance variables
available to your templates. Helper methods live in Ruby modules and
can be included with the `:helpers` option to `Brochure.app`:

    module AssetHelper
      def asset_path(filename)
        local_path = File.join(application.asset_root, filename)
        if File.file?(local_path)
          cache_buster = "?#{Digest::MD5.hexdigest(IO.read(local_path))}"
        else
          cache_buster = ""
        end
        "#{filename}#{cache_buster}"
      end
    end

    run Brochure.app(ROOT, :helpers => [AssetHelper])

Similarly, instance variables can be defined with the `:assigns`
option:

    run Brochure.app(ROOT, :assigns => { :domain => "37signals.com" })


# Installation

    $ gem install brochure

Requires [Hike](http://github.com/sstephenson/hike),
[Rack](http://rack.rubyforge.org/), and
[Tilt](http://github.com/rtomayko/tilt).


# License

Copyright (c) 2010 Sam Stephenson and Josh Peek.

Released under the MIT license. See `LICENSE` for details.
