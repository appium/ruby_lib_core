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

      @@driver.execute_script('mobile: setPermission', {service: 'calendar', state: 'yes', bundleId: 'com.apple.mobilecal'})

      @@driver.activate_app('com.apple.mobilecal')

      @@driver.find_element(:accessibility_id, 'Continue').click # TODO: if it exist, we tap the button
      # Alert must not appear since the permission already allowed
      error = assert_raises ::Selenium::WebDriver::Error::NoSuchAlertError do
        @@driver.switch_to.alert.text
      end
      assert_equal 'unknown error', error.message
      @@driver.terminate_app('com.apple.mobilecal')

      @@driver.execute_script('mobile: setPermission', {service: 'calendar', state: 'unset', bundleId: 'com.apple.mobilecal'})
      @@driver.activate_app('com.apple.mobilecal')

      assert @@driver.switch_to.alert.text.include?('Allow “Calendar” to access your location while you are using the app?')
    end

  end
end
# rubocop:enable Style/ClassVars
