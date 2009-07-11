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
    query_path = query_string.empty? ? path : "#{path}?#{query_string}"
    
    response = Logger.current.info_with_time "Loading http://#{@server + query_path}" do
      Net::HTTP.get_response(@server, query_path)
    end

    @headers          = response
    @status           = response.code.to_i
    
    if found?
      self.content      = response.body
      true
    else
      Logger.current.error "Not found"
      false
    end
  end
  
  def found?
    @status == 200
  end
  
  def cache_control
    headers['Cache-Control']
  end  
  
  def download_original(&block)
    image = RemoteImage.new(@server, find_original_path, query_string)
    image.download
    image
  end  
end

