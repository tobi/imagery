require 'logger'
require 'benchmark'

class Logger
  
  def self.current
    @logger
  end
  
  def self.current=(logger)
    @logger = logger
  end

end

class RequestAwareLogger < Logger
    
  
  def intend
    @intend = true
    yield
  ensure 
    @intend = false
  end
  
  def buffer
    @buffer = []
    begin
      yield
    ensure
      buffer = @buffer
      @buffer = nil
      buffer.each do |method, msg|
        self.send(method, msg)
      end      
    end
    
  end
  
  def info_with_time(msg)
    result = nil
    rm = Benchmark.realtime { result = yield }
    info msg + " [%.3fs]" % [rm]
    result
  end
  
  [:info, :warn, :error, :debug].each do |level|
    define_method(level) do |msg|
      
      msg = @intend ? "  " + msg : msg
      
      if @buffer
        @buffer << [level, msg]
      else
        super(msg)
      end
    end
  end
  
  
end