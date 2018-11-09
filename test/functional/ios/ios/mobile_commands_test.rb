require 'test_helper'

# $ rake test:func:ios TEST=test/functional/ios/ios/mobile_commands_test.rb
# rubocop:disable Style/ClassVars
class AppiumLibCoreTest
  class DriverTest < AppiumLibCoreTest::Function::TestCase
    def setup
      @@core ||= ::Appium::Core.for(Caps.ios)
      @@driver ||= @@core.start_driver
    end

    def teardown
      save_reports(@driver)
    end

    # @since Appium 1.9.2
    # Requires simulator
    def test_permission
      require 'pry' # Will remove after finishing creating a test scenario
      binding.pry

      @@driver.execute_script('mobile: setPermission', {service: 'calendar', state: 'unset', bundleId: 'com.example.apple-samplecode.UICatalog'})
# open settings => go to calendar => No UICatalog
      assert @@driver.execute_script('mobile: getPermission', {service: 'calendar',bundleId: 'com.example.apple-samplecode.UICatalog'}) == 'unset'

      @@driver.execute_script('mobile: setPermission', {service: 'calendar', state: 'yes', bundleId: 'com.example.apple-samplecode.UICatalog'})
      # open settings => go to calendar => Exist UICatalog
      assert @@driver.execute_script('mobile: getPermission', {service: 'calendar',bundleId: 'com.example.apple-samplecode.UICatalog'}) == 'yes'

      @@driver.activate_app('com.apple.settings')

      @@driver.execute_script('mobile: setPermission', {service: 'calendar', state: 'no', bundleId: 'com.example.apple-samplecode.UICatalog'})
      # open settings => go to calendar => No UICatalog
      assert @@driver.execute_script('mobile: getPermission', {service: 'calendar',bundleId: 'com.example.apple-samplecode.UICatalog'}) == 'no'

      # Privacy => Calendars => UICatalog's switch

      # Note: Once we change the status, we never back to "unset"
      @@driver.execute_script('mobile: setPermission', {service: 'calendar', state: 'unset', bundleId: 'com.example.apple-samplecode.UICatalog'})

      assert @@driver.switch_to.alert.text.include?('Allow “Calendar” to access your location while you are using the app?')

      # applesimutils --byId 3CB9E12B-419C-49B1-855A-45322861F1F7  --bundle com.apple.mobilecal --setPermissions calendar=yes
    end

  end
end
# rubocop:enable Style/ClassVars
