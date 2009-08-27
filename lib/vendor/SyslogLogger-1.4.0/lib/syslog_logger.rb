require 'syslog'
require 'logger'

##
# SyslogLogger is a Logger work-alike that logs via syslog instead of to a
# file.  You can add SyslogLogger to your Rails production environment to
# aggregate logs between multiple machines.
#
# By default, SyslogLogger uses the program name 'rails', but this can be
# changed via the first argument to SyslogLogger.new.
#
# NOTE! You can only set the SyslogLogger program name when you initialize
# SyslogLogger for the first time.  This is a limitation of the way
# SyslogLogger uses syslog (and in some ways, a limitation of the way
# syslog(3) works).  Attempts to change SyslogLogger's program name after the
# first initialization will be ignored.
#
# = Sample usage with Rails
#
# == config/environment/production.rb
#
# Add the following lines:
#
#   require 'syslog_logger'
#   RAILS_DEFAULT_LOGGER = SyslogLogger.new
#
# == config/environment.rb
#
# In 0.10.0, change this line:
#
#   RAILS_DEFAULT_LOGGER = Logger.new("#{RAILS_ROOT}/log/#{RAILS_ENV}.log")
#
# to:
#
#   RAILS_DEFAULT_LOGGER ||= Logger.new("#{RAILS_ROOT}/log/#{RAILS_ENV}.log")
#
# Other versions of Rails should have a similar change.
#
# == BSD syslog setup
#
# === /etc/syslog.conf
#
# Add the following lines:
#
#  !rails
#  *.*                                             /var/log/production.log
#
# Then touch /var/log/production.log and signal syslogd with a HUP
# (killall -HUP syslogd, on FreeBSD).
#
# === /etc/newsyslog.conf
#
# Add the following line:
#
#   /var/log/production.log                 640  7     *    @T00  Z
#
# This creates a log file that is rotated every day at midnight, gzip'd, then
# kept for 7 days.  Consult newsyslog.conf(5) for more details.
#
# == syslog-ng setup
#
# === syslog-ng.conf
#
# destination rails_log { file("/var/log/production.log"); };
# filter f_rails { program("rails.*"); };
# log { source(src); filter(f_rails); destination(rails_log); };
#
# == Starting
#
# Now restart your Rails app.  Your production logs should now be showing up
# in /var/log/production.log.  If you have mulitple machines, you can log them
# all to a central machine with remote syslog logging for analysis.  Consult
# your syslogd(8) manpage for further details.

class SyslogLogger

  ##
  # The version of SyslogLogger you are using.

  VERSION = '1.4.0'

  ##
  # Maps Logger warning types to syslog(3) warning types.

  LOGGER_MAP = {
    :unknown => :alert,
    :fatal   => :err,
    :error   => :warning,
    :warn    => :notice,
    :info    => :info,
    :debug   => :debug,
  }

  ##
  # Maps Logger log levels to their values so we can silence.

  LOGGER_LEVEL_MAP = {}

  LOGGER_MAP.each_key do |key|
    LOGGER_LEVEL_MAP[key] = Logger.const_get key.to_s.upcase
  end

  ##
  # Maps Logger log level values to syslog log levels.

  LEVEL_LOGGER_MAP = {}

  LOGGER_LEVEL_MAP.invert.each do |level, severity|
    LEVEL_LOGGER_MAP[level] = LOGGER_MAP[severity]
  end

  ##
  # Builds a methods for level +meth+.

  def self.make_methods(meth)
    eval <<-EOM, nil, __FILE__, __LINE__ + 1
      def #{meth}(message = nil)
        return true if #{LOGGER_LEVEL_MAP[meth]} < @level
        SYSLOG.#{LOGGER_MAP[meth]} clean(message || yield)
        return true
      end

      def #{meth}?
        @level <= Logger::#{meth.to_s.upcase}
      end
    EOM
  end

  LOGGER_MAP.each_key do |level|
    make_methods level
  end

  ##
  # Log level for Logger compatibility.

  attr_accessor :level

  ##
  # Fills in variables for Logger compatibility.  If this is the first
  # instance of SyslogLogger, +program_name+ may be set to change the logged
  # program name.
  #
  # Due to the way syslog works, only one program name may be chosen.

  def initialize(program_name = 'rails')
    @level = Logger::DEBUG

    return if defined? SYSLOG
    self.class.const_set :SYSLOG, Syslog.open(program_name)
  end

  ##
  # Almost duplicates Logger#add.  +progname+ is ignored.

  def add(severity, message = nil, progname = nil, &block)
    severity ||= Logger::UNKNOWN
    return true if severity < @level
    message = clean(message || block.call)
    SYSLOG.send LEVEL_LOGGER_MAP[severity], clean(message)
    return true
  end

  ##
  # Allows messages of a particular log level to be ignored temporarily.
  #
  # Can you say "Broken Windows"?

  def silence(temporary_level = Logger::ERROR)
    old_logger_level = @level
    @level = temporary_level
    yield
  ensure
    @level = old_logger_level
  end

  private

  ##
  # Clean up messages so they're nice and pretty.

  def clean(message)
    message = message.to_s.dup
    message.strip!
    message.gsub!(/%/, '%%') # syslog(3) freaks on % (printf)
    message.gsub!(/\e\[[^m]*m/, '') # remove useless ansi color codes
    return message
  end

end

