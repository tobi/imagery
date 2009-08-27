require 'test/unit'
require 'tempfile'
require 'syslog_logger'

module MockSyslog; end

class << MockSyslog

  @line = nil

  SyslogLogger::LOGGER_MAP.values.uniq.each do |level|
    eval <<-EOM
      def #{level}(message)
        @line = "#{level.to_s.upcase} - \#{message}"
      end
    EOM
  end

  attr_reader :line
  attr_reader :program_name

  def open(program_name)
    @program_name = program_name
  end

  def reset
    @line = ''
  end

end

SyslogLogger.const_set :SYSLOG, MockSyslog

class TestLogger < Test::Unit::TestCase

  LEVEL_LABEL_MAP = {
    Logger::DEBUG => 'DEBUG',
    Logger::INFO => 'INFO',
    Logger::WARN => 'WARN',
    Logger::ERROR => 'ERROR',
    Logger::FATAL => 'FATAL',
    Logger::UNKNOWN => 'ANY',
  }

  def setup
    @logger = Logger.new(nil)
  end

  class Log
    attr_reader :line, :label, :datetime, :pid, :severity, :progname, :msg
    def initialize(line)
      @line = line
      /\A(\w+), \[([^#]*)#(\d+)\]\s+(\w+) -- (\w*): ([\x0-\xff]*)/ =~ @line
      @label, @datetime, @pid, @severity, @progname, @msg = $1, $2, $3, $4, $5, $6
    end
  end

  def log_add(severity, msg, progname = nil, &block)
    log(:add, severity, msg, progname, &block)
  end

  def log(msg_id, *arg, &block)
    Log.new(log_raw(msg_id, *arg, &block))
  end

  def log_raw(msg_id, *arg, &block)
    logdev = Tempfile.new(File.basename(__FILE__) + '.log')
    @logger.instance_eval { @logdev = Logger::LogDevice.new(logdev) }
    assert_equal true, @logger.__send__(msg_id, *arg, &block)
    logdev.open
    msg = logdev.read
    logdev.close
    msg
  end

  def test_initialize
    assert_equal Logger::DEBUG, @logger.level
  end

  def test_add
    msg = log_add nil,           'unknown level message' # nil == unknown
    assert_equal LEVEL_LABEL_MAP[Logger::UNKNOWN], msg.severity

    msg = log_add Logger::FATAL, 'fatal level message'
    assert_equal LEVEL_LABEL_MAP[Logger::FATAL],   msg.severity

    msg = log_add Logger::ERROR, 'error level message'
    assert_equal LEVEL_LABEL_MAP[Logger::ERROR],   msg.severity

    msg = log_add Logger::WARN,  'warn level message'
    assert_equal LEVEL_LABEL_MAP[Logger::WARN],    msg.severity

    msg = log_add Logger::INFO,  'info level message'
    assert_equal LEVEL_LABEL_MAP[Logger::INFO],    msg.severity

    msg = log_add Logger::DEBUG, 'debug level message'
    assert_equal LEVEL_LABEL_MAP[Logger::DEBUG],   msg.severity
  end

  def test_add_level_unknown
    @logger.level = Logger::UNKNOWN

    msg = log_add nil,           'unknown level message' # nil == unknown
    assert_equal LEVEL_LABEL_MAP[Logger::UNKNOWN], msg.severity

    msg = log_add Logger::FATAL, 'fatal level message'
    assert_equal '', msg.line

    msg = log_add Logger::ERROR, 'error level message'
    assert_equal '', msg.line

    msg = log_add Logger::WARN,  'warn level message'
    assert_equal '', msg.line

    msg = log_add Logger::INFO,  'info level message'
    assert_equal '', msg.line

    msg = log_add Logger::DEBUG, 'debug level message'
    assert_equal '', msg.line
  end

  def test_add_level_fatal
    @logger.level = Logger::FATAL

    msg = log_add nil,           'unknown level message' # nil == unknown
    assert_equal LEVEL_LABEL_MAP[Logger::UNKNOWN], msg.severity

    msg = log_add Logger::FATAL, 'fatal level message'
    assert_equal LEVEL_LABEL_MAP[Logger::FATAL],   msg.severity

    msg = log_add Logger::ERROR, 'error level message'
    assert_equal '', msg.line

    msg = log_add Logger::WARN,  'warn level message'
    assert_equal '', msg.line

    msg = log_add Logger::INFO,  'info level message'
    assert_equal '', msg.line

    msg = log_add Logger::DEBUG, 'debug level message'
    assert_equal '', msg.line
  end

  def test_add_level_error
    @logger.level = Logger::ERROR

    msg = log_add nil,           'unknown level message' # nil == unknown
    assert_equal LEVEL_LABEL_MAP[Logger::UNKNOWN], msg.severity

    msg = log_add Logger::FATAL, 'fatal level message'
    assert_equal LEVEL_LABEL_MAP[Logger::FATAL],   msg.severity

    msg = log_add Logger::ERROR, 'error level message'
    assert_equal LEVEL_LABEL_MAP[Logger::ERROR],   msg.severity

    msg = log_add Logger::WARN,  'warn level message'
    assert_equal '', msg.line

    msg = log_add Logger::INFO,  'info level message'
    assert_equal '', msg.line

    msg = log_add Logger::DEBUG, 'debug level message'
    assert_equal '', msg.line
  end

  def test_add_level_warn
    @logger.level = Logger::WARN

    msg = log_add nil,           'unknown level message' # nil == unknown
    assert_equal LEVEL_LABEL_MAP[Logger::UNKNOWN], msg.severity

    msg = log_add Logger::FATAL, 'fatal level message'
    assert_equal LEVEL_LABEL_MAP[Logger::FATAL],   msg.severity

    msg = log_add Logger::ERROR, 'error level message'
    assert_equal LEVEL_LABEL_MAP[Logger::ERROR],   msg.severity

    msg = log_add Logger::WARN,  'warn level message'
    assert_equal LEVEL_LABEL_MAP[Logger::WARN],   msg.severity

    msg = log_add Logger::INFO,  'info level message'
    assert_equal '', msg.line

    msg = log_add Logger::DEBUG, 'debug level message'
    assert_equal '', msg.line
  end

  def test_add_level_info
    @logger.level = Logger::INFO

    msg = log_add nil,           'unknown level message' # nil == unknown
    assert_equal LEVEL_LABEL_MAP[Logger::UNKNOWN], msg.severity

    msg = log_add Logger::FATAL, 'fatal level message'
    assert_equal LEVEL_LABEL_MAP[Logger::FATAL],   msg.severity

    msg = log_add Logger::ERROR, 'error level message'
    assert_equal LEVEL_LABEL_MAP[Logger::ERROR],   msg.severity

    msg = log_add Logger::WARN,  'warn level message'
    assert_equal LEVEL_LABEL_MAP[Logger::WARN],    msg.severity

    msg = log_add Logger::INFO,  'info level message'
    assert_equal LEVEL_LABEL_MAP[Logger::INFO],    msg.severity

    msg = log_add Logger::DEBUG, 'debug level message'
    assert_equal '', msg.line
  end

  def test_add_level_debug
    @logger.level = Logger::DEBUG

    msg = log_add nil,           'unknown level message' # nil == unknown
    assert_equal LEVEL_LABEL_MAP[Logger::UNKNOWN], msg.severity

    msg = log_add Logger::FATAL, 'fatal level message'
    assert_equal LEVEL_LABEL_MAP[Logger::FATAL],   msg.severity

    msg = log_add Logger::ERROR, 'error level message'
    assert_equal LEVEL_LABEL_MAP[Logger::ERROR],   msg.severity

    msg = log_add Logger::WARN,  'warn level message'
    assert_equal LEVEL_LABEL_MAP[Logger::WARN],    msg.severity

    msg = log_add Logger::INFO,  'info level message'
    assert_equal LEVEL_LABEL_MAP[Logger::INFO],    msg.severity

    msg = log_add Logger::DEBUG, 'debug level message'
    assert_equal LEVEL_LABEL_MAP[Logger::DEBUG],   msg.severity
  end

  def test_unknown
    msg = log :unknown, 'unknown level message'
    assert_equal LEVEL_LABEL_MAP[Logger::UNKNOWN], msg.severity

    @logger.level = Logger::UNKNOWN
    msg = log :unknown, 'unknown level message'
    assert_equal LEVEL_LABEL_MAP[Logger::UNKNOWN], msg.severity

    @logger.level = Logger::FATAL
    msg = log :unknown, 'unknown level message'
    assert_equal LEVEL_LABEL_MAP[Logger::UNKNOWN], msg.severity

    @logger.level = Logger::ERROR
    msg = log :unknown, 'unknown level message'
    assert_equal LEVEL_LABEL_MAP[Logger::UNKNOWN], msg.severity

    @logger.level = Logger::WARN
    msg = log :unknown, 'unknown level message'
    assert_equal LEVEL_LABEL_MAP[Logger::UNKNOWN], msg.severity

    @logger.level = Logger::INFO
    msg = log :unknown, 'unknown level message'
    assert_equal LEVEL_LABEL_MAP[Logger::UNKNOWN], msg.severity

    @logger.level = Logger::DEBUG
    msg = log :unknown, 'unknown level message'
    assert_equal LEVEL_LABEL_MAP[Logger::UNKNOWN], msg.severity
  end

  def test_unknown_eh
    @logger.level = Logger::UNKNOWN
    assert_equal true, @logger.unknown?

    @logger.level = Logger::UNKNOWN + 1
    assert_equal false, @logger.unknown?
  end

  def test_fatal
    msg = log :fatal, 'fatal level message'
    assert_equal LEVEL_LABEL_MAP[Logger::FATAL], msg.severity

    @logger.level = Logger::UNKNOWN
    msg = log :fatal, 'fatal level message'
    assert_equal '', msg.line

    @logger.level = Logger::FATAL
    msg = log :fatal, 'fatal level message'
    assert_equal LEVEL_LABEL_MAP[Logger::FATAL], msg.severity

    @logger.level = Logger::ERROR
    msg = log :fatal, 'fatal level message'
    assert_equal LEVEL_LABEL_MAP[Logger::FATAL], msg.severity

    @logger.level = Logger::WARN
    msg = log :fatal, 'fatal level message'
    assert_equal LEVEL_LABEL_MAP[Logger::FATAL], msg.severity

    @logger.level = Logger::INFO
    msg = log :fatal, 'fatal level message'
    assert_equal LEVEL_LABEL_MAP[Logger::FATAL], msg.severity

    @logger.level = Logger::DEBUG
    msg = log :fatal, 'fatal level message'
    assert_equal LEVEL_LABEL_MAP[Logger::FATAL], msg.severity
  end

  def test_fatal_eh
    @logger.level = Logger::FATAL
    assert_equal true, @logger.fatal?

    @logger.level = Logger::UNKNOWN
    assert_equal false, @logger.fatal?
  end

  def test_error
    msg = log :error, 'error level message'
    assert_equal LEVEL_LABEL_MAP[Logger::ERROR], msg.severity

    @logger.level = Logger::UNKNOWN
    msg = log :error, 'error level message'
    assert_equal '', msg.line

    @logger.level = Logger::FATAL
    msg = log :error, 'error level message'
    assert_equal '', msg.line

    @logger.level = Logger::ERROR
    msg = log :error, 'error level message'
    assert_equal LEVEL_LABEL_MAP[Logger::ERROR], msg.severity

    @logger.level = Logger::WARN
    msg = log :error, 'error level message'
    assert_equal LEVEL_LABEL_MAP[Logger::ERROR], msg.severity

    @logger.level = Logger::INFO
    msg = log :error, 'error level message'
    assert_equal LEVEL_LABEL_MAP[Logger::ERROR], msg.severity

    @logger.level = Logger::DEBUG
    msg = log :error, 'error level message'
    assert_equal LEVEL_LABEL_MAP[Logger::ERROR], msg.severity
  end

  def test_error_eh
    @logger.level = Logger::ERROR
    assert_equal true, @logger.error?

    @logger.level = Logger::FATAL
    assert_equal false, @logger.error?
  end

  def test_warn
    msg = log :warn, 'warn level message'
    assert_equal LEVEL_LABEL_MAP[Logger::WARN], msg.severity

    @logger.level = Logger::UNKNOWN
    msg = log :warn, 'warn level message'
    assert_equal '', msg.line

    @logger.level = Logger::FATAL
    msg = log :warn, 'warn level message'
    assert_equal '', msg.line

    @logger.level = Logger::ERROR
    msg = log :warn, 'warn level message'
    assert_equal '', msg.line

    @logger.level = Logger::WARN
    msg = log :warn, 'warn level message'
    assert_equal LEVEL_LABEL_MAP[Logger::WARN], msg.severity

    @logger.level = Logger::INFO
    msg = log :warn, 'warn level message'
    assert_equal LEVEL_LABEL_MAP[Logger::WARN], msg.severity

    @logger.level = Logger::DEBUG
    msg = log :warn, 'warn level message'
    assert_equal LEVEL_LABEL_MAP[Logger::WARN], msg.severity
  end

  def test_warn_eh
    @logger.level = Logger::WARN
    assert_equal true, @logger.warn?

    @logger.level = Logger::ERROR
    assert_equal false, @logger.warn?
  end

  def test_info
    msg = log :info, 'info level message'
    assert_equal LEVEL_LABEL_MAP[Logger::INFO], msg.severity

    @logger.level = Logger::UNKNOWN
    msg = log :info, 'info level message'
    assert_equal '', msg.line

    @logger.level = Logger::FATAL
    msg = log :info, 'info level message'
    assert_equal '', msg.line

    @logger.level = Logger::ERROR
    msg = log :info, 'info level message'
    assert_equal '', msg.line

    @logger.level = Logger::WARN
    msg = log :info, 'info level message'
    assert_equal '', msg.line

    @logger.level = Logger::INFO
    msg = log :info, 'info level message'
    assert_equal LEVEL_LABEL_MAP[Logger::INFO], msg.severity

    @logger.level = Logger::DEBUG
    msg = log :info, 'info level message'
    assert_equal LEVEL_LABEL_MAP[Logger::INFO], msg.severity
  end

  def test_info_eh
    @logger.level = Logger::INFO
    assert_equal true, @logger.info?

    @logger.level = Logger::WARN
    assert_equal false, @logger.info?
  end

  def test_debug
    msg = log :debug, 'debug level message'
    assert_equal LEVEL_LABEL_MAP[Logger::DEBUG], msg.severity

    @logger.level = Logger::UNKNOWN
    msg = log :debug, 'debug level message'
    assert_equal '', msg.line

    @logger.level = Logger::FATAL
    msg = log :debug, 'debug level message'
    assert_equal '', msg.line

    @logger.level = Logger::ERROR
    msg = log :debug, 'debug level message'
    assert_equal '', msg.line

    @logger.level = Logger::WARN
    msg = log :debug, 'debug level message'
    assert_equal '', msg.line

    @logger.level = Logger::INFO
    msg = log :debug, 'debug level message'
    assert_equal '', msg.line

    @logger.level = Logger::DEBUG
    msg = log :debug, 'debug level message'
    assert_equal LEVEL_LABEL_MAP[Logger::DEBUG], msg.severity
  end

  def test_debug_eh
    @logger.level = Logger::DEBUG
    assert_equal true, @logger.debug?

    @logger.level = Logger::INFO
    assert_equal false, @logger.debug?
  end

end

class TestSyslogLogger < TestLogger

  def setup
    super
    @logger = SyslogLogger.new
  end

  class Log
    attr_reader :line, :label, :datetime, :pid, :severity, :progname, :msg
    def initialize(line)
      @line = line
      return unless /\A(\w+) - (.*)\Z/ =~ @line
      severity, @msg = $1, $2
      severity = SyslogLogger::LOGGER_MAP.invert[severity.downcase.intern]
      @severity = severity.to_s.upcase
      @severity = 'ANY' if @severity == 'UNKNOWN'
    end
  end

  def log_add(severity, msg, progname = nil, &block)
    log(:add, severity, msg, progname, &block)
  end

  def log(msg_id, *arg, &block)
    Log.new(log_raw(msg_id, *arg, &block))
  end

  def log_raw(msg_id, *arg, &block)
    assert_equal true, @logger.__send__(msg_id, *arg, &block)
    msg = MockSyslog.line
    MockSyslog.reset
    return msg
  end

end

