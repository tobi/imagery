require 'RMagick'
require 'fileutils'
require 'patron'

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
  
  def session
    @@session ||= begin
      sess = Patron::Session.new
      sess.timeout = 10      
      sess.headers['User-Agent'] = 'imagery/1.0'
      sess
    end
  end
    
  def download(path_info)          
    session.base_url = "http://#{server}"
    
    response = Logger.current.info_with_time "Loading http://#{server}#{path_info}" do
      session.get(path_info)
    end

    @path    = path_info.split('?')[0]
    @headers = response.headers
    @status  = response.status
      
    if found?
      self.content      = response.body
      true
    else
      Logger.current.error "Not found"
      false
    end
  end
end

