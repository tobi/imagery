
class RemoteProxy
  include SendFile
  
  def initialize(app)
    @app = app
  end
  
  def call(env)
    request = Rack::Request.new(env)
        
    requested_file = Image.new(ORIGIN_SERVER, env['PATH_INFO'] + (env['QUERY_STRING'].empty? ? '' : "?#{env['QUERY_STRING']}"))
  
    # If file exists we simply sent it to the client.         
    if requested_file.found?
      Logger.current.info "Requested file exists upstream."
      
      send_file(requested_file)
    else
      @app.call(env)
    end
  end  
end
