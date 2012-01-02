require 'syslog'
require 'logger'
require 'active_support/buffered_logger'

class BufferedSyslogger < ActiveSupport::BufferedLogger
  attr_reader :ident, :options, :facility

  MAPPING = {
    Logger::DEBUG => Syslog::LOG_DEBUG,
    Logger::INFO => Syslog::LOG_INFO,
    Logger::WARN => Syslog::LOG_NOTICE,
    Logger::ERROR => Syslog::LOG_WARNING,
    Logger::FATAL => Syslog::LOG_ERR,
    Logger::UNKNOWN => Syslog::LOG_ALERT
  }

  #
  # Initializes default options for the logger
  # <tt>ident</tt>:: the name of your program [default=$0].
  # <tt>options</tt>::  syslog options [default=<tt>Syslog::LOG_PID | Syslog::LOG_CONS</tt>].
  #                     Correct values are:
  #                       LOG_CONS    : writes the message on the console if an error occurs when sending the message;
  #                       LOG_NDELAY  : no delay before sending the message;
  #                       LOG_PERROR  : messages will also be written on STDERR;
  #                       LOG_PID     : adds the process number to the message (just after the program name)
  # <tt>facility</tt>:: the syslog facility [default=nil] Correct values include:
  #                       Syslog::LOG_DAEMON
  #                       Syslog::LOG_USER
  #                       Syslog::LOG_SYSLOG
  #                       Syslog::LOG_LOCAL2
  #                       Syslog::LOG_NEWS
  #                       etc.
  #
  # Usage:
  #   logger = BufferedSyslogger.new("my_app", Syslog::LOG_PID | Syslog::LOG_CONS, Syslog::LOG_LOCAL0)
  #   logger.level = Logger::INFO # use Logger levels
  #   logger.warn "warning message"
  #   logger.debug "debug message"
  #
  def initialize(ident = $0, options = Syslog::LOG_PID | Syslog::LOG_CONS, facility = nil)
    @ident = ident
    @options = options || (Syslog::LOG_PID | Syslog::LOG_CONS)
    @facility = facility

    @level = Logger::INFO
    @buffer = Hash.new { |h,k| h[k] = [] }
    @auto_flushing = 1
    @guard = Mutex.new
  end

  # Low level method to add a message.
  # +severity+::  the level of the message. One of Logger::DEBUG, Logger::INFO, Logger::WARN, Logger::ERROR, Logger::FATAL, Logger::UNKNOWN
  # +message+:: the message string. If nil, the method will call the block and use the result as the message string.
  # +progname+:: unsupported, kept for compatibility
  def add(severity, message = nil, progname = nil, &block)
    return if @level > severity
    (message || (block && block.call) || progname).to_s.chomp.tap do |m|
      buffer << [severity, m]
      auto_flush
    end
  end

  def flush
    @guard.synchronize do
      unless buffer.empty?
        old_buffer = buffer
        Syslog.open(@ident, @options, @facility) do |s|
          s.mask = Syslog::LOG_UPTO(MAPPING[@level])
          old_buffer.each do |severity, message|
            message.split(/[\r\f\n]/).each { |m| s.log(MAPPING[severity], m.gsub('%', '%%')) }
          end
        end
      end

      # Important to do this even if buffer was empty or else @buffer will
      # accumulate empty arrays for each request where nothing was logged.
      clear_buffer
    end
  end

  def close
    flush
  end

end
