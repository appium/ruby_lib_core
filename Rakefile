require 'bundler/gem_tasks'
require 'rake/testtask'
require 'yard'

desc('setup development environment')
task :setup do |_t, _args|
  system %w(bundle install)
end

namespace :test do
  namespace :func do
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

  desc('Run all unit tests in test directory')
  Rake::TestTask.new(:unit) do |t|
    t.libs << 'test'
    t.libs << 'lib'
    t.test_files = FileList['test/unit/**/*_test.rb']
  end

  namespace :unit do
    desc('Run all iOS related unit tests in test directory')
    Rake::TestTask.new(:ios) do |t|
      t.libs << 'test'
      t.libs << 'lib'
      t.test_files = FileList['test/unit/ios/**/*_test.rb']
    end

    desc('Run all Android related unit tests in test directory')
    Rake::TestTask.new(:android) do |t|
      t.libs << 'test'
      t.libs << 'lib'
      t.test_files = FileList['test/unit/android/**/*_test.rb']
    end
  end
end

desc('Generate yardoc')
YARD::Rake::YardocTask.new do |t|
  t.files   = ['lib/**/*.rb']
end
