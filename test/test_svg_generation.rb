$LOAD_PATH.unshift '..'

require "test/unit"
require 'rubygems'
require 'fakeweb'
require 'rack'
require File.dirname(__FILE__) + '/../image_server'

FakeWeb.allow_net_connect = false
FakeWeb.register_uri(:get, "http://static.shopify.com/image.svg", :body => File.read( File.dirname(__FILE__) + '/assets/fish.svg'), :content_type => "image/svg+xml", :cache_control => 'public, max-age=0')
FakeWeb.register_uri(:get, "http://static.shopify.com/image.svg.png", :status => 404)

class TestRemoteProxy < Test::Unit::TestCase
  StandardResponse = [200, {}, ['OK']]
  ExpectedResponse = [200, {"Cache-Control"=>"public, max-age=0", "Content-Type"=>"text/plain"}, ["Hello World!"]]
  
  
  def test_successfull_call
    assert SvgGenerator.from_url('static.shopify.com', '/image.svg.png')        
  end

  def test_wrong_filename
    assert_equal nil, SvgGenerator.from_url('static.shopify.com', '/image.svg')
    assert_equal nil, SvgGenerator.from_url('static.shopify.com', '/image.png')
    assert_equal nil, SvgGenerator.from_url('static.shopify.com', '/image.svg.bmp')
  end

end