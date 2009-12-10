require 'rack/file'

class File #:nodoc:
  alias :to_path :path
end

# To make this work you have to add:
#
# location /cache/ {
  # internal;
  # alias /mnt/data/cache/rack/body;
# }
# 
# to nginx config


class AccelRedirect
  F = ::File

  def initialize(app, variation=nil)
    @app = app
  end

  def call(env)
    status, headers, body   = @app.call(env)
    if body.respond_to?(:to_path)
      
      path = body.to_path            
      url  = path.sub(/^#{ENV['CACHE_LOCATION']}/i, '/cache')
      
      Logger.current.info " => sending #{url} through nginx"
            
      headers['Content-Length'] = '0'
      headers['X-Accel-Redirect'] = url 
      body = []
    end
    [status, headers, body]
  end

end
