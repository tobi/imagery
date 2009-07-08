require 'rubygems'
require 'lib/transformations'
require 'lib/image'
require 'lib/remote_image'

class ImageServer
  NotFound = [404, {'Content-Type' => 'text/html'}, ['<h1>File not Found</h1>']]

  def call(env)
    
    request = Rack::Request.new(env)
    
    if request.request_method == "PURGE" 
      return [404, {'Content-Type' => 'text/plain', 'Cache-Control' => 'private, must-revalidate, max-age=0'}, ['OK']]
    end
    
    requested_file = RemoteImage.new(OriginServer, request.path, request.query_string)  
  
    # If file exists we simply sent it to the client. 
    if requested_file.download

      $logger.info 'Hit: Direct'
      
      requested_file.to_response

    # If it doesn't exist but it's an image and a variant was requested we will
    # go look for the original image and resize it according to the request.  
    elsif requested_file.image? && requested_file.variant?
        
      origin_file = RemoteImage.new(OriginServer, requested_file.find_original_path, request.query_string)
      if origin_file.download
        origin_file.transform_content!(requested_file.variant)

        $logger.info "Hit: Origin, transformed:#{requested_file.variant}"    

        origin_file.to_response
      else
        $logger.info 'Miss, original'    
        NotFound
      end
    else
      $logger.info 'Miss, requested'    
      NotFound
    end
  end
end