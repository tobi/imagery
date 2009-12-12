require 'logger'
require 'benchmark'

begin
  require File.dirname(__FILE__) + "/vendor/SyslogLogger-1.4.0/lib/syslog_logger"
rescue LoadError
  STDERR.puts('** Syslog is not supported')
end

class Logger

  module Extensions
    def self.included(base)
      base.send(:define_method, :mutex) {@mutex ||= Mutex.new}
    end

    def intend
      @intend = true
      yield
    ensure
      @intend = false
    end

    def buffer
      self.mutex.synchronize do
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

  def self.current
    @logger
  end

  def self.current=(logger)
    @logger = logger
  end

end

Logger.send :include, Logger::Extensions

if defined? SyslogLogger
  SyslogLogger.send :include, Logger::Extensions
end
