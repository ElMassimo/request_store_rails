require 'bundler/gem_tasks'
require 'rake/testtask'

$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'request_store_rails/version'

name = 'request_store_rails'
version = RequestStoreRails::VERSION

task :gem => :build
task :build do
  system "gem build #{name}.gemspec"
end

task :install => :build do
  system "sudo gem install #{name}-#{version}.gem"
end

task :release => :build do
  system "git tag -a v#{version} -m 'Tagging #{version}'"
  system 'git push --tags'
  system "gem push #{name}-#{version}.gem"
  system "rm #{name}-#{version}.gem"
end

Rake::TestTask.new do |t|
  t.libs << "lib"
  t.test_files = FileList['test/*_test.rb']
  t.ruby_opts = ['-r./test/test_helper.rb']
  t.verbose = true
end

task :default => :test
