require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe BufferedSyslogger do

  let(:syslog) { mock("syslog", :mask= => true) }

  it "should log to the default syslog facility, with the default options" do
    logger = BufferedSyslogger.new
    Syslog.should_receive(:open).with($0, Syslog::LOG_PID | Syslog::LOG_CONS, nil).and_yield(syslog)
    syslog.should_receive(:log).with(Syslog::LOG_NOTICE, "Some message")
    logger.warn "Some message"
  end

  it "should log to the user facility, with specific options" do
    logger = BufferedSyslogger.new("my_app", Syslog::LOG_PID, Syslog::LOG_USER)
    Syslog.should_receive(:open).with("my_app", Syslog::LOG_PID, Syslog::LOG_USER).and_yield(syslog)
    syslog.should_receive(:log).with(Syslog::LOG_NOTICE, "Some message")
    logger.warn "Some message"
  end

  %w{debug info warn error fatal unknown}.each do |logger_method|
    it { should respond_to :"#{logger_method}" }
    it { should respond_to :"#{logger_method}?" }
  end

  describe '#add' do
    subject { BufferedSyslogger.new("my_app", Syslog::LOG_PID, Syslog::LOG_USER) }

    it { should respond_to(:add) }

    it "should correctly log a simple message" do
      Syslog.should_receive(:open).and_yield(syslog)
      syslog.should_receive(:log).with(Syslog::LOG_INFO, "message")
      subject.add(Logger::INFO, "message")
    end

    it "should take the message from the block if :message is nil" do
      Syslog.should_receive(:open).and_yield(syslog)
      syslog.should_receive(:log).with(Syslog::LOG_INFO, "my message")
      subject.add(Logger::INFO) { "my message" }
    end
  end

  context "when used in buffered mode" do
    before { subject.auto_flushing = false }

    it "without flushing should not send anything to syslog" do
      Syslog.should_not_receive(:open)
      subject.warn "Self destruction in progress..."
    end

    it "should send the messages to syslog when flushed" do
      Syslog.should_receive(:open).and_yield(syslog)
      syslog.should_receive(:log).with(Syslog::LOG_INFO, "Self destruction in 3...")
      syslog.should_receive(:log).with(Syslog::LOG_NOTICE, "2..")
      syslog.should_receive(:log).with(Syslog::LOG_WARNING, "1.")
      subject.info "Self destruction in 3..."
      subject.warn "2.."
      subject.error "1."
      subject.flush
    end

    it "should split messages with multiple lines and send separately" do
      Syslog.should_receive(:open).and_yield(syslog)
      syslog.should_receive(:log).with(Syslog::LOG_WARNING, "Self destruction in 3...")
      syslog.should_receive(:log).with(Syslog::LOG_WARNING, "2..")
      syslog.should_receive(:log).with(Syslog::LOG_WARNING, "1.")
      subject.error "Self destruction in 3...\n2..\n1."
      subject.flush
    end
  end

  # TODO: test logger level
end
