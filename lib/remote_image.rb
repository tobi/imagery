require 'RMagick'
require 'fileutils'
require 'net/http'

class RemoteImage < Image
  VARIANT_DELIMITER = '_'
  attr_reader :headers
  attr_reader :status
  attr_reader :server, :path, :query_string

  def initialize(server, path, query_string = nil)
    @server = server
    @path   = path     
    @query_string = query_string
  end
  
  def content_type
    headers['Content-Type'] || super
  end
  
  def download(path = path)
    query_path = "#{path}#{query_string}"
    $logger.info "Loading http://#{@server + query_path}"
    response = Net::HTTP.get_response(@server, query_path)

    @headers          = response
    @status           = response.status.to_i
    
    if found?
      self.content      = response.body
      true
    else
      $logger.error "Not found"
      false
    end
  end
  
  def found?
    @status == 200
  end
  
  def download_original(&block)
    image = RemoteImage.new(@server, find_original_path)
    image.download
    image
  end  
end

