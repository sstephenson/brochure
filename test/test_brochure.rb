require "brochure"
require "rack/test"
require "test/unit"

module Brochure
  class TestApplication < Application
    def warn(*) end
  end
end

class BrochureTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Brochure::TestApplication.new File.dirname(__FILE__)
  end

  def test_templates_are_rendered_when_present
    get "/signup"
    assert last_response.ok?
    assert_equal "<h1>Sign up</h1>", last_response.body.strip
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
    assert last_response.not_found?
  end

  def test_404_is_returned_when_a_template_is_not_present
    get "/nonexistent"
    assert last_response.not_found?
  end

  def test_404_is_returned_for_a_directory_when_an_index_template_is_not_present
    get "/shared"
    assert last_response.not_found?
  end

  def test_500_is_returned_when_a_template_raises_an_exception
    get "/error"
    assert last_response.server_error?
  end

  def test_403_is_returned_when_path_is_outside_root
    get "/../passwd"
    assert_equal 403, last_response.status
  end

  def test_partials_can_be_rendered_from_templates
    get "/help"
    assert last_response.body["<title>Help</title>"]
  end

  def test_helpers_are_available_to_templates
    get "/help"
    assert last_response.body["<a href=\"/\">Home</a>"]
  end
end
