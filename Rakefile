require 'rubygems'
require 'rake/testtask'
require 'rubygems/package_task'
require 'fileutils'
require './test/unit/resources'

Dir['tasks/**/*.rake'].each { |t| load t }

task :default => 'test:all'

class SVNXTestTask < Rake::TestTask
  def initialize name, pattern
    super name do |t|
      t.libs << 'lib'
      t.libs << 'test'
      t.libs << 'test/unit'
      t.pattern = 'test/' + pattern
      t.warning = true
      t.verbose = true
    end
  end
end

SVNXTestTask.new 'test:unit', 'unit/**/*_test.rb'
SVNXTestTask.new 'test:integration', 'integration/**/*_test.rb'
SVNXTestTask.new 'test:all', '**/*_test.rb'

task :build_fixtures do
  Resources.instance.generate
end

spec = Gem::Specification.new do |s| 
  s.name               = "svnx"
  s.version            = "0.0.2"
  s.author             = "Jeff Pace"
  s.email              = "jeugenepace@gmail.com"
  s.homepage           = "http://www.incava.org/projects/svnx"
  s.platform           = Gem::Platform::RUBY
  s.summary            = "Wrapper around Subversion command line."
  s.description        = "A bridge between Subversion functionality, via the command line, and Ruby."
  s.files              = FileList["{lib}/**/*"].to_a
  s.require_path       = "lib"
  s.test_files         = FileList["{test}/**/*test.rb"].to_a
  s.has_rdoc           = false
  s.bindir             = 'bin'
  s.license            = 'MIT'

  s.add_dependency("logue", ">= 1.0.0")
  s.add_dependency("rainbow", ">= 1.1.4")
end
 
Gem::PackageTask.new(spec) do |pkg| 
  pkg.need_zip = true 
  pkg.need_tar_gz = true 
end 
