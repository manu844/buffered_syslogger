# encoding: utf-8
if RUBY_VERSION =~ /1.9/
Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8
end

Gem::Specification.new do |s|
  s.name         = "buffered_syslogger"
  s.version      = "0.1.1"
  s.date         = "2010-10-12"
  s.authors      = ["László Bácsi", "Cyril Rohr"]
  s.email        = "lackac@secretsaucepartners.com"
  s.homepage     = "http://github.com/sspinc/buffered_syslogger"
  s.summary      = "Buffered syslogger based on the syslogger gem."
  s.description  = <<-EOH
A drop-in replacement for the Rails 3 default BufferedLogger library,
that logs to syslog instead of a log file. Builds on the syslogger gem.
  EOH

  s.files        = Dir['lib/**/*','spec/**/*'] + %w(README.rdoc LICENSE)
  s.extra_rdoc_files = %w(LICENSE README.rdoc)
  s.rdoc_options = %w(--charset=UTF-8)
  s.platform     = Gem::Platform::RUBY
  s.require_path = 'lib'
  s.rubyforge_project = 'nowarning'
  s.required_rubygems_version = '>= 1.3.6'

  s.add_runtime_dependency "activesupport", "~> 3.2.18"
  s.add_development_dependency "rspec", ">= 2.0.0"
end
