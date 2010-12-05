require "brochure"
require "rack/test"
require "test/unit"

ENV['RACK_ENV'] = 'test'

require File.expand_path("../fixtures/default/helpers/link_helper", __FILE__)

class BrochureTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app(name = :default, options = {})
    @app ||= Brochure.app(
      File.dirname(__FILE__) + "/fixtures/#{name}",
      :helpers => [LinkHelper],
      :assigns => { :domain => "37signals.com" },
      :template_options => options[:template_options]
    )
  end

  def test_templates_are_rendered_when_present
    get "/signup"
    assert last_response.ok?
    assert_equal "<h1>Sign up</h1>", last_response.body.strip
    assert_equal "text/html; charset=utf-8", last_response.content_type
  end

  def test_index_templates_are_rendered_for_directories
    get "/"
    assert last_response.ok?
    assert_equal "<h1>Welcome to Zombocom</h1>", last_response.body.strip
  end

  def test_extensions_are_ignored
    get "/signup.html"
    assert last_response.ok?
    assert_equal "<h1>Sign up</h1>", last_response.body.strip
  end

  def test_partials_are_not_publicly_accessible
    get "/shared/_head"
    assert last_response.forbidden?
  end

  def test_static_asset
    get "/screen.css"
    assert last_response.ok?
  end

  def test_404_is_returned_when_a_template_is_not_present
    get "/nonexistent"
    assert last_response.not_found?
    assert_match %r{<h1>404 Not Found</h1>}, last_response.body
  end

  def test_404_is_returned_for_a_directory_when_an_index_template_is_not_present
    get "/shared"
    assert last_response.not_found?
  end

  def test_custom_404_is_returned_when_a_404_html_template_is_not_present
    app :custom404

    get "/nonexistent"
    assert last_response.not_found?
    assert_match %r{<h1>Oops, that isn't right.</h1>}, last_response.body #'
  end

  def test_500_is_returned_when_a_template_raises_an_exception
    get "/error"
    assert last_response.server_error?
  end

  def test_403_is_returned_when_path_is_outside_root
    get "/../passwd"
    assert_equal 403, last_response.status
  end

  def test_template_has_access_to_request
    get "/help/search?term=export"
    assert last_response.body["<h1>Search for \"export\"</h1>"]
  end

  def test_partials_can_be_rendered_from_templates
    get "/help"
    assert last_response.body["<title>Help</title>"]
  end

  def test_helpers_are_available_to_templates
    get "/help"
    assert last_response.body["<a href=\"/\">Home</a>"]
  end

  def test_missing_partial_raises_an_error
    get "/help/partial_error"
    assert last_response.server_error?
  end

  def test_render_layout_with_block
    get "/blog"
    assert last_response.body["<title>Blog</title>"]
    assert last_response.body["<h1>Latest</h1>"]

    get "/blog/2010"
    assert last_response.body["<title>Blog - 2010</title>"]
    assert last_response.body["<h1>Posts from 2010</h1>"]
  end

  def test_using_other_tilt_template_types
    get "/hello?name=Sam"
    assert last_response.body["<p>Hello Sam</p>"]
  end

  def test_templates_in_plugins
    get "/common"
    assert last_response.body["Common template"]
  end

  def test_rendering_partials_in_plugins
    get "/help"
    assert last_response.body["<div>Footer</div>"]
  end

  def test_assigns_are_available_in_templates
    get "/hello"
    assert last_response.body['<a href="http://37signals.com/">Home</a>']
  end

  def test_alternate_template_format
    get "/hello.js"
    assert last_response.body['var domain = "37signals.com";']
    assert_equal "application/javascript", last_response.content_type
  end

  def test_engineless_templates
    get "/engineless"
    assert last_response.ok?
    assert last_response.body["Engineless <%= template %>"]
  end

  def test_haml_with_layout
    get "/haml_with_layout"
    assert last_response.body["<title>Blog</title>"]
    assert last_response.body["<h1>Latest</h1>"]
  end

  def test_haml_with_xhtml_format
    app :default, :template_options => { ".haml" => { :format => :xhtml } }
    get "/doctype"
    assert last_response.body["<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">\n"]
  end

  def test_haml_with_html5_format
    app :default, :template_options => { ".haml" => { :format => :html5 } }
    get "/doctype"
    assert last_response.body["<!DOCTYPE html>\n"]
  end
end
