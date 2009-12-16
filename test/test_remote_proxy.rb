$LOAD_PATH.unshift '..'

require "test/unit"
require 'rubygems'
require 'rack'
require 'mocha'

require File.dirname(__FILE__) + '/../image_server'
require 'config/env'

# FakeWeb.allow_net_connect = false
# FakeWeb.register_uri(:get, "http://static.shopify.com/test.txt", :body => "Hello World!", :content_type => "text/plain", :cache_control => 'public, max-age=0')
# FakeWeb.register_uri(:get, "http://static.shopify.com/test2.txt", :status => 404)
# FakeWeb.register_uri(:get, "http://static.shopify.com/test3.txt?abc", :body => "Hello World!", :content_type => "text/plain", :cache_control => 'public, max-age=0')
# 
class TestRemoteProxy < Test::Unit::TestCase
  StandardResponse = [200, {}, ['OK']]
  ExpectedResponse = [200,
   {"Cache-Control"=>"public, max-age=0", "Content-Type"=>"text/plain", "ETag"=>"abc", "Content-Length"=>12, 'Last-Modified' => "Mon, 24 Aug 2009 18:07:15 GMT"},
   ["Hello World!"]]
  
  def setup
    @headers = {'Content-Type' => "text/plain", 'Cache-Control' => 'public, max-age=0', 'ETag' => 'abc', 'Last-Modified' => "Mon, 24 Aug 2009 18:07:15 GMT"}
    
    Patron::Session.any_instance.stubs(:get).with('/test.txt').returns( 
      stub(:headers => @headers, :body => 'Hello World!', :status => 200)
    )
    
    Patron::Session.any_instance.stubs(:get).with('/test2.txt').returns( 
      stub(:headers => {}, :status => 404)
    )
    
    Patron::Session.any_instance.stubs(:get).with('/test3.txt?abc').returns( 
      stub(:headers => @headers, :body => 'Hello World!', :status => 200)
    )
    
    
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