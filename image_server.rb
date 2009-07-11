require 'lib/logger_ext'
require 'lib/transformations'
require 'lib/image'
require 'lib/remote_image'

require 'config/environment'

class ImageServer
  NotFound = [404, {'Content-Type' => 'text/html'}, ['<h1>File not Found</h1>']].freeze
  
  def initialze(options = {})
    @options = options    
  end  
  
  def call(env)
    request = Rack::Request.new(env)
    
    requested_file = RemoteImage.new(ORIGIN_SERVER, request.path, request.query_string)  
  
    # If file exists we simply sent it to the client.         
    if requested_file.download
      
      return requested_file.to_response

    # If it doesn't exist but it's an image and a variant was requested we will
    # go look for the original image and resize it according to the request.  
    elsif requested_file.image? && requested_file.variant?
        
      origin_file = RemoteImage.new(ORIGIN_SERVER, requested_file.find_original_path, request.query_string)
      if origin_file.download
        origin_file.transform_content!(requested_file.variant)

        return origin_file.to_response
      end
    end

    NotFound        
  end
end