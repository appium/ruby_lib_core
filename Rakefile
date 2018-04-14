require 'bundler/gem_tasks'
require 'rake/testtask'
require 'yard'
require 'rubocop/rake_task'

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

    desc('Run all common related unit tests in test directory')
    Rake::TestTask.new(:common) do |t|
      t.libs << 'test'
      t.libs << 'lib'
      t.test_files = FileList['test/unit/common/**/*_test.rb']
    end
  end
end

desc('Generate yardoc')
YARD::Rake::YardocTask.new do |t|
  t.files   = %w(lib/**/*.rb)
end

desc('Execute RuboCop static code analysis')
RuboCop::RakeTask.new(:rubocop) do |t|
  t.patterns = %w(lib test script)
  t.options = %w(-D)
  t.fail_on_error = true
end

desc("print commands which haven't implemented yet.")
namespace :commands do
  require './script/commands'

  task :mjsonwp do |_t, _args|
    c = Script::CommandsChecker.new
    c.get_mjsonwp_routes
    c.get_all_command_path './mjsonwp_routes.js'
    c.all_diff_commands_mjsonwp.each { |key, value| puts("command: #{key}, method: #{value}") }
  end

  task :w3c do |_t, _args|
    c = Script::CommandsChecker.new
    c.get_mjsonwp_routes
    c.get_all_command_path './mjsonwp_routes.js'
    c.all_diff_commands_w3c.each { |key, value| puts("command: #{key}, method: #{value}") }
  end
end
