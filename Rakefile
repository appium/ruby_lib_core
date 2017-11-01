require 'bundler/gem_tasks'
require 'rake/testtask'
require 'yard'

desc('setup development environment')
task :setup do |_t, _args|
  system %w(bundle install)
end

desc('Run all tests in test directory')
Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.libs << 'lib'
  t.test_files = FileList['test/**/*_test.rb']
end

namespace :func_test do
  desc('Run all iOS related tests in test directory')
  Rake::TestTask.new(:ios) do |t|
    t.libs << 'test'
    t.libs << 'lib'
    t.test_files = FileList['test/functional/ios/**/*_test.rb']
  end

  desc('Run all Android related tests in test directory')
  Rake::TestTask.new(:android) do |t|
    t.libs << 'test'
    t.libs << 'lib'
    t.test_files = FileList['test/functional/android/**/*_test.rb']
  end
end

namespace :unit_test do
  desc('Run all iOS related tests in test directory')
  Rake::TestTask.new(:ios) do |t|
    t.libs << 'test'
    t.libs << 'lib'
    t.test_files = FileList['test/unit/ios/**/*_test.rb']
  end

  desc('Run all Android related tests in test directory')
  Rake::TestTask.new(:android) do |t|
    t.libs << 'test'
    t.libs << 'lib'
    t.test_files = FileList['test/unit/android/**/*_test.rb']
  end
end


task :default => :test

desc('Generate yardoc')
YARD::Rake::YardocTask.new do |t|
  t.files   = ['lib/**/*.rb']
end
