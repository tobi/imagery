
class LoggedRequest
  
  def initialize(app)
    @app = app
  end
    
  def call(env)    
    
    request = Rack::Cache::Request.new(env)
    
    resp = nil

    Logger.current.info "#{request.request_method} #{request.path} [#{request.ip}]"
    
    secs = Benchmark.realtime do 
      Logger.current.intend do 
        resp = @app.call(env)
      end      
    end
    
    Logger.current.info((resp[0] == 200 ? 'Success' : "Error [#{resp[0]}]") + " after %.3fs Cache: %s" % [secs, resp[1]['X-Rack-Cache']])
    
    resp
  end
end