require 'test_helper'

# $ rake test:func:ios TEST=test/functional/ios/ios/mobile_commands_test.rb
class AppiumLibCoreTest
  class MobileCommandsTest < AppiumLibCoreTest::Function::TestCase
    def setup
      @core = ::Appium::Core.for(Caps.ios)
    end

    def teardown
      save_reports(@driver)
    end

    # @since Appium 1.10.0
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

    # @since Appium 1.10.0
    def test_siri
      @driver = @core.start_driver
      assert @driver.app_state('com.example.apple-samplecode.UICatalog') == :running_in_foreground
      siri_state = @driver.app_state('com.apple.SiriViewService')
      assert siri_state == :running_in_background_suspended || siri_state == :not_running

      @driver.execute_script 'mobile: activateSiri', { text: 'hello, siri' }

      e = @driver.find_element :accessibility_id, 'hello, siri'
      assert_equal 'hello, siri', e.text

      assert_equal :running_in_foreground, @driver.app_state('com.example.apple-samplecode.UICatalog')
      assert @driver.app_state('com.apple.SiriViewService') == :running_in_background

      @driver.activate_app 'com.example.apple-samplecode.UICatalog'
      sleep 1 # wait a bit for switching siri service with the test target app
      assert_equal :running_in_background_suspended, @driver.app_state('com.apple.SiriViewService')
    end

    def test_source
      @driver = @core.start_driver

      json = @driver.execute_script 'mobile: source', { format: :json }
      xml = @driver.execute_script 'mobile: source', { format: :xml }

      assert !json.empty?
      assert !xml.empty?
    end
  end
end
