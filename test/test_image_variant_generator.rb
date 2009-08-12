$LOAD_PATH.unshift '..'

require "test/unit"
require 'rubygems'
require 'fakeweb'
require 'rack'
require File.dirname(__FILE__) + '/../image_server'

FakeWeb.allow_net_connect = false
FakeWeb.register_uri(:get, "http://static.shopify.com/image.png", :body => File.read( File.dirname(__FILE__) + '/assets/fish.png'), :content_type => "image/png", :cache_control => 'public, max-age=0')
FakeWeb.register_uri(:get, "http://static.shopify.com/failed_image.png", :status => 404)

class TestRemoteProxy < Test::Unit::TestCase  
  
  def test_successfull_call
    assert ImageVariantGenerator.from_url('static.shopify.com', '/image_pico.png')        
    assert ImageVariantGenerator.from_url('static.shopify.com', '/image_small.png')        
  end  
  
  def test_return_nil_on_404
    assert_equal nil, ImageVariantGenerator.from_url('static.shopify.com', '/failed_image_pico.png')        
  end

  def test_wrong_filename
    assert_equal nil, ImageVariantGenerator.from_url('static.shopify.com', '/image.png')
    assert_equal nil, ImageVariantGenerator.from_url('static.shopify.com', '/image_whatever.png')
    assert_equal nil, ImageVariantGenerator.from_url('static.shopify.com', '/image.tga')
  end

end