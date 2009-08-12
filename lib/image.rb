require 'RMagick'
require 'fileutils'
require 'net/http'

class Image
  attr_accessor :content
  attr_reader :headers
  attr_reader :status
  attr_reader :server
  
  def initialize(server, path)
    @server = server
    @path = path    
    download(path)
  end
  
  def content_type
    headers['Content-Type']
  end
  
  def cache_control
    headers['Cache-Control']
  end      

  def found?
    @status == 200
  end  
  
  def basename
    File.basename(@path)
  end

  def basename_no_ext
    File.basename(@path, ext)
  end
    
  def ext
    File.extname(@path)
  end
  
  def dirname
    File.dirname(@path)
  end    
  
  private
    
  def download(path_info)      
    response = Logger.current.info_with_time "Loading http://#{server}#{path_info}" do
      Net::HTTP.get_response(server, path_info)
    end

    @path    = path_info.split('?')[0]
    @headers = response
    @status  = response.code.to_i
      
    if found?
      self.content      = response.body
      true
    else
      Logger.current.error "Not found"
      false
    end
  end
end

