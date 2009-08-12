$LOAD_PATH.unshift '..'

require "test/unit"
require 'rubygems'
require 'fakeweb'
require 'rack'
require File.dirname(__FILE__) + '/../image_server'

FakeWeb.allow_net_connect = false
FakeWeb.register_uri(:get, "http://static.shopify.com/test.txt", :body => "Hello World!", :content_type => "text/plain", :cache_control => 'public, max-age=0')
FakeWeb.register_uri(:get, "http://static.shopify.com/test2.txt", :status => 404)
FakeWeb.register_uri(:get, "http://static.shopify.com/test3.txt?abc", :body => "Hello World!", :content_type => "text/plain", :cache_control => 'public, max-age=0')

class TestRemoteProxy < Test::Unit::TestCase
  StandardResponse = [200, {}, ['OK']]
  ExpectedResponse = [200,
   {"Cache-Control"=>"public, max-age=0", "Content-Type"=>"text/plain"},
   ["Hello World!"]]
  
  def setup
    @app = RemoteProxy.new lambda { StandardResponse }
  end
  
  def test_successfull_call
    env = Rack::MockRequest.env_for("/test.txt", {})    
    assert_equal ExpectedResponse, @app.call(env)        
  end

  def test_remote_miss_continues_chain
    env = Rack::MockRequest.env_for("/test2.txt", {})
    
    assert_equal StandardResponse, @app.call(env)        
  end

  def test_remote_calls_preserve_query_parameters
    env = Rack::MockRequest.env_for("/test3.txt?abc", {})    
    assert_equal ExpectedResponse, @app.call(env)        
  end
end