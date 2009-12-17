require File.join(File.dirname(__FILE__), 'helper')

FakeWeb.allow_net_connect = false
FakeWeb.register_uri(:get, "http://static.shopify.com/image.png", :body => File.read( File.dirname(__FILE__) + '/assets/fish.png'), :content_type => "image/png", :cache_control => 'public, max-age=0')
FakeWeb.register_uri(:get, "http://static.shopify.com/failed_image.png", :status => 404)

class TestRemoteProxy < Test::Unit::TestCase  
  
  def setup
    @headers = {'Content-Type' => "image/png", 'Cache-Control' => 'public, max-age=0', 'ETag' => 'abc', 'Last-Modified' => "Mon, 24 Aug 2009 18:07:15 GMT"}
    
    Patron::Session.any_instance.stubs(:get).with('/image.png').returns( 
      stub(:headers => @headers, :body => File.read( File.dirname(__FILE__) + '/assets/fish.png'), :status => 200)
    )

    Patron::Session.any_instance.stubs(:get).with('/failed_image.png').returns( 
      stub(:headers => {}, :status => 404)
    )
  end
  
  def test_successfull_call
    assert Imagery::ImageVariantGenerator.from_url('static.shopify.com', '/image_pico.png')        
    assert Imagery::ImageVariantGenerator.from_url('static.shopify.com', '/image_small.png')        
  end  
  
  def test_return_nil_on_404
    assert_equal nil, Imagery::ImageVariantGenerator.from_url('static.shopify.com', '/failed_image_pico.png')        
  end

  def test_wrong_filename
    assert_equal nil, Imagery::ImageVariantGenerator.from_url('static.shopify.com', '/image.png')
    assert_equal nil, Imagery::ImageVariantGenerator.from_url('static.shopify.com', '/image_whatever.png')
    assert_equal nil, Imagery::ImageVariantGenerator.from_url('static.shopify.com', '/image.tga')
  end

end