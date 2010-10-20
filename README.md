Brochure
========

A Rack application for serving static sites with ERB templates.

Sample application structure:

    app/
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
    run Brochure.app(File.dirname(__FILE__))

URLs are automatically mapped to template names. So `/` will render
`app/templates/index.html.erb`, `/signup` will render
`app/templates/signup.html.erb`, `/help/` will render
`app/templates/help/index.html.erb`, and so on.

Templates can render partials. Partials are denoted by a leading
underscore in their filename. So `<%= render "shared/header" %>` will
render `app/templates/shared/_header.html.erb` inline.

# Installation

    $ gem install brochure

Requires [Hike](http://github.com/sstephenson/hike),
[Rack](http://rack.rubyforge.org/), and
[Tilt](http://github.com/rtomayko/tilt).

# License

Copyright (c) 2010 Sam Stephenson and Josh Peek.

Released under the MIT license. See `LICENSE` for details.
