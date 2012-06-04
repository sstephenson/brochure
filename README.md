<img src="https://github.com/downloads/sstephenson/brochure/logo.png"
width="250" height="135" alt="Brochure">

Brochure is a Rack application for serving static sites with ERB
templates (or any of the many [template languages supported by
Tilt](http://github.com/rtomayko/tilt/blob/master/TEMPLATES.md#readme)).
It's the good parts of PHP wrapped up in a little Ruby package &mdash;
perfect for serving the marketing site for your Rails app.


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
    root = File.dirname(__FILE__)
    run Brochure.app(root)


## Automatic URL mapping

URLs are automatically mapped to template names:

* `/` &rarr; `templates/index.html.erb`
* `/signup` &rarr; `templates/signup.html.erb`
* `/help/` &rarr; `templates/help/index.html.erb`


## Partials and helpers

Templates can render partials. A partial is denoted by a leading
underscore in its filename. So `<%= render "shared/header" %>` will
render `templates/shared/_header.html.erb` inline.

Partials can `<%= yield %>` back to the templates that render
them. You can use this technique to extract common header and footer
markup into a single layout file, for example.

Templates have access to the Rack environment via the `env` method and
to the Brochure application via the `application`
method. Additionally, a `Rack::Request` wrapper around the Rack
environment is available via the `request` method.

You can print HTML-escaped strings in your templates with the `h`
helper.

## Layouts

There are two ways you can handle layouts with brochure. First is the
traditional:

    <%= render 'shared/header', :title => 'Products' %>
    <p>Here is a list of my products:</p>
    <ul>
      <li>Product 1</li>
      <li>Product 2</li>
      ....
    </ul>
    <%= render 'shared/footer' %>

The file shared/_header.html.erb would contain the top of your page.
Note the title in the header:

    <html>
      <head>
        <title><%= title %></title>
      </head>
      <body>
        <img src="logo.png" alt="Site Logo">

The file shared/_footer.html.erb would wrap things up:

      </body>
    </html>

Splitting your layout in two files can get confusing sometimes to ensure
proper opening and closing tags. Since partials can `<%= yield %>` back
to the templates that render them an alternative is:

    <% render 'layout', :title => 'Products' do %>
      <p>Here is a list of my products:</p>
      <ul>
        <li>Product 1</li>
        <li>Product 2</li>
        ....
      </ul>
    <% end %>

The file _layout.html.erb would then contain both the header and footer
yielding where the content is:

    <html>
      <head>
        <title><%= title %></title>
      </head>
      <body>
        <img src="logo.png" alt="Site Logo">
        <%= yield %>
      </body>
    </html>

## Custom helper methods and instance variables

You can make additional helper methods and instance variables
available to your templates. Helper methods live in Ruby modules and
can be included with the `:helpers` option to `Brochure.app`:

    module AssetHelper
      def asset_path(filename)
        local_path = File.join(application.asset_root, filename)
        digest = Digest::MD5.hexdigest(IO.read(local_path))
        "/#{filename}?#{digest}"
      end
    end

    run Brochure.app(root, :helpers => [AssetHelper])

Similarly, instance variables can be defined with the `:assigns`
option:

    run Brochure.app(root, :assigns => { :domain => "37signals.com" })


## Tilt template options

You can specify global [Tilt template
options](https://github.com/rtomayko/tilt/blob/master/TEMPLATES.md#readme)
on a per-engine basis with `:template_options`:

    run Brochure.app(root, :template_options => {
      ".haml" => { :format => :html5 },
      ".md"   => { :smart  => true }
    })


# Installation

    $ gem install brochure

Requires [Hike](http://github.com/sstephenson/hike),
[Rack](http://rack.rubyforge.org/), and
[Tilt](http://github.com/rtomayko/tilt).


# License

Copyright (c) 2010 Sam Stephenson and Josh Peek.

Released under the MIT license. See `LICENSE` for details.
