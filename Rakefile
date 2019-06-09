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
      tmp_build = File.expand_path('tmp/Build/Products/')
      puts "#{tmp_build} is used for tests. Make sure they are not older version" if File.exist?(tmp_build)

      t.libs << 'test'
      t.libs << 'lib'
      t.test_files = FileList[ENV['TESTS'] ? ENV['TESTS'].split(',') : 'test/functional/ios/**/*_test.rb']
    end

    desc('Run all Android related tests in test directory')
    Rake::TestTask.new(:android) do |t|
      t.libs << 'test'
      t.libs << 'lib'
      t.test_files = FileList[ENV['TESTS'] ? ENV['TESTS'].split(',') : 'test/functional/android/**/*_test.rb']
    end
  end

  desc('Run all unit tests in test directory')
  Rake::TestTask.new(:unit) do |t|
    t.libs << 'test'
    t.libs << 'lib'
    t.test_files = FileList[ENV['TESTS'] ? ENV['TESTS'].split(',') : 'test/unit/**/*_test.rb']
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

namespace :android do
  desc('uninstall all of test apks from a test device')
  task :uninstall_test_apks do |_t, _args|
    `adb uninstall io.appium.uiautomator2.server.test`
    `adb uninstall io.appium.uiautomator2.server`
    `adb uninstall io.appium.settings`
    `adb uninstall io.appium.android.ime`
    `adb uninstall io.appium.espressoserver.test`
  end

  desc('Generate and launch android emulators')
  task :gen_device do |_t, _args|
    SWARMER_VERSION = '0.2.4'.freeze
    CPU_ARCHITECTURE = 'x86'.freeze
    IMAGE = 'google_apis'.freeze
    ANDROID_API = 27
    system %W(
      curl
      --fail
      --location https://jcenter.bintray.com/com/gojuno/swarmer/swarmer/#{SWARMER_VERSION}/swarmer-#{SWARMER_VERSION}.jar
      --output /tmp/swarmer.jar
    ).join(' ')
    cmds = (1..3).reduce([]) do |acc, number|
      acc << %W(
        --emulator-name test#{number}
        --package "system-images;android-#{ANDROID_API};#{IMAGE};#{CPU_ARCHITECTURE}"
        --android-abi #{IMAGE}/#{CPU_ARCHITECTURE}
        --path-to-config-ini test/functional/android/emulator_config.ini
        --emulator-start-options -netdelay none -netspeed full -screen touch -prop persist.sys.language=en -prop persist.sys.country=US
      ).join(' ')
    end

    system %w(java -jar /tmp/swarmer.jar start).concat(cmds).flatten.join(' ')
  end
end

desc('Generate yardoc')
YARD::Rake::YardocTask.new do |t|
  t.files = %w(lib/**/*.rb)
end

desc('Execute RuboCop static code analysis')
RuboCop::RakeTask.new(:rubocop) do |t|
  t.patterns = %w(lib test script)
  t.options = %w(-D)
  t.fail_on_error = true
end

desc('print commands which Ruby client has not implemented them yet')
namespace :commands do
  require './script/commands'

  desc('Mobile JSON protocol')
  task :mjsonwp do |_t, _args|
    c = Script::CommandsChecker.new
    c.get_mjsonwp_routes
    c.get_all_command_path './mjsonwp_routes.js'
    c.all_diff_commands_mjsonwp.each { |key, value| puts("command: #{key}, method: #{value}") }
  end

  desc('W3C protocol')
  task :w3c do |_t, _args|
    c = Script::CommandsChecker.new
    c.get_mjsonwp_routes
    c.get_all_command_path './mjsonwp_routes.js'
    c.all_diff_commands_w3c.each { |key, value| puts("command: #{key}, method: #{value}") }
  end
end
