require 'rubygems'
require 'rake'

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

RSpec::Core::RakeTask.new(:rcov) do |spec|
  spec.rcov = true
end

task :test => :check_dependencies

task :default => :spec

def gemspec
  @gemspec ||= begin
    file = File.expand_path('buffered_syslogger.gemspec', File.dirname(__FILE__))
    eval(File.read(file), binding, file)
  end
end

require 'rake/gempackagetask'
Rake::GemPackageTask.new(gemspec) do |pkg|
  pkg.gem_spec = gemspec
end
task :gem => [:gemspec]

task :install => :repackage do
  sh %{gem install pkg/#{gemspec.name}-#{gemspec.version}}
end

desc "Validate the gemspec"
task :gemspec do
  gemspec.validate
end

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "buffered_syslogger #{gemspec.version}"
  rdoc.options = %w(--charset=UTF-8)
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
