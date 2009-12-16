require File.join(File.dirname(__FILE__), 'helper')

class TestRemoteProxy < Test::Unit::TestCase
  StandardResponse = [200, {}, ['OK']]
  ExpectedResponse = [200, {"Cache-Control"=>"public, max-age=0", "Content-Type"=>"text/plain"}, ["Hello World!"]]
  
  def setup
  end
    
  def test_successfull_call
    Patron::Session.any_instance.expects(:get).with('/image.svg').returns( stub(:headers => {}, :body =>  File.read( File.dirname(__FILE__) + '/assets/fish.svg'), :status => 200))
    
    assert SvgGenerator.from_url('static.shopify.com', '/image.svg.png')        
  end

  def test_wrong_filename
    
    assert_equal nil, SvgGenerator.from_url('static.shopify.com', '/image.svg')
    assert_equal nil, SvgGenerator.from_url('static.shopify.com', '/image.png')
    assert_equal nil, SvgGenerator.from_url('static.shopify.com', '/image.svg.bmp')
  end

end