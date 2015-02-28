require 'rubygems'
require 'rake'
require 'rake/clean'
require 'rake/gempackagetask'
require 'rake/rdoctask'
require 'rake/testtask'

NAME = "matrixorbital-glk"
VERS = "0.0.1"
CLEAN.include ['pkg', 'rdoc']

Gem::manage_gems

spec = Gem::Specification.new do |s|
  s.name              = NAME
  s.version           = VERS
  s.author            = "Nicholas J Humfrey"
  s.email             = "njh@aelius.com"
  s.homepage          = "http://github.com/njh/ruby-matrixorbital-glk"
  s.platform          = Gem::Platform::RUBY
  s.summary           = "A ruby gem to interface Matrix Orbital's GLK series of LCD Screens." 
  s.files             = FileList["Rakefile", "lib/matrixorbital/glk.rb", "examples/*"]
  s.require_path      = "lib"
  
  # rdoc
  s.has_rdoc          = true
  s.extra_rdoc_files  = ["README.md", "NEWS.md", "LICENSE.md"]
  
  # Dependencies
  s.add_dependency "rake"
end

desc "Default: package up the gem."
task :default => :package

task :build_package => [:repackage]
Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_zip = false
  pkg.need_tar = true
  pkg.gem_spec = spec
end

desc "Run :package and install the resulting .gem"
task :install => :package do
  sh %{sudo gem install --local pkg/#{NAME}-#{VERS}.gem}
end

desc "Run :clean and uninstall the .gem"
task :uninstall => :clean do
  sh %{sudo gem uninstall #{NAME}}
end



## Testing
#desc "Run all the specification tests"
#Rake::TestTask.new(:spec) do |t|
#  t.warning = true
#  t.verbose = true
#  t.pattern = 'spec/*_spec.rb'
#end
  
desc "Check the syntax of all ruby files"
task :check_syntax do
  `find . -name "*.rb" |xargs -n1 ruby -c |grep -v "Syntax OK"`
  puts "* Done"
end

## Documentation
desc "Generate documentation for the library"
Rake::RDocTask.new("rdoc") { |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = "Matrix Orbital GLK Documentation"
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.main = "README.md"
  rdoc.rdoc_files.include("README.md", "NEWS.md", "COPYING", "lib/matrixorbital/glk.rb")
}
