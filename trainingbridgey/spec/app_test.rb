ENV['RACK_ENV'] = 'test'
 
require 'minitest/autorun'
require 'rack/test'
require_relative '../bridgey'
 
class MainAppTest < Minitest::Test
  include Rack::Test::Methods 
 
  def app 
    Bridgey
  end
 
  def test_displays_main_page
    get '/'
    assert last_response.ok?
    assert last_response.body.include?("Step")
  end
end
