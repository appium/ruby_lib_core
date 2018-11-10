require 'test_helper'

# $ rake test:func:ios TEST=test/functional/ios/ios/mobile_commands_test.rb
class AppiumLibCoreTest
  class DriverTest < AppiumLibCoreTest::Function::TestCase
    def teardown
      save_reports(@driver)
    end

    # @since Appium 1.9.2
    # Requires simulator
    def test_permission
      caps = Caps.ios.dup
      caps[:caps][:permissions] = '{"com.example.apple-samplecode.UICatalog": { "calendar": "YES", "photos": "no" }}'
      core = ::Appium::Core.for(caps)
      @driver = core.start_driver

      assert @driver.execute_script('mobile: getPermission',
                                    { service: 'calendar', bundleId: 'com.example.apple-samplecode.UICatalog' }) == 'yes'
      assert @driver.execute_script('mobile: getPermission',
                                    { service: 'photos', bundleId: 'com.example.apple-samplecode.UICatalog' }) == 'no'

      @driver.activate_app('com.apple.Preferences')
      @driver.find_element(:accessibility_id, 'Privacy').click

      @driver.find_element(:accessibility_id, 'Calendars').click
      el = @driver.find_element(:accessibility_id, 'UICatalog')
      assert_equal '1', el.value

      @driver.back

      @driver.find_element(:accessibility_id, 'Photos').click
      el = @driver.find_element(:accessibility_id, 'Never')
      assert_equal 'Never', el.value
    end
  end
end
