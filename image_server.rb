require 'rubygems'
require 'lib/send_file'
require 'lib/middlewear/cache_purge'
require 'lib/middlewear/logged_request'
require 'lib/middlewear/remote_proxy'
require 'lib/middlewear/server_name'
require 'lib/middlewear/favicon_filter'
require 'lib/logger_ext'
require 'lib/transformations'
require 'lib/svg_generator'
require 'lib/image_variant_generator'
require 'lib/image'

require 'config/environment'

class ImageServer
  include SendFile
  
  NotFound = [404, {'Content-Type' => 'text/html'}, ['<h1>File not Found</h1>']].freeze
        
  def call(env)    
    Logger.current.info 'Attempting to generate missing file...'
    
    [SvgGenerator, ImageVariantGenerator].each do |generator|                
      if image = generator.from_url(ORIGIN_SERVER, env['PATH_INFO'] + (env['QUERY_STRING'].empty? ? '' : "?#{env['QUERY_STRING']}"))        
                
        return send_file(image)
      end
    end
    
    Logger.current.info 'No generator available'
    
    NotFound
  end
  
end