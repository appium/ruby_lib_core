require 'test_helper'

# $ rake test:func:ios TEST=test/functional/ios/ios/mobile_commands_test.rb
class AppiumLibCoreTest
  module Ios
    class MobileCommandsTest < AppiumLibCoreTest::Function::TestCase
      def setup
        @core = ::Appium::Core.for(Caps.ios)
      end

      def teardown
        save_reports(@driver)
      end

      def test_select_picker_wheel
        @driver = @core.start_driver
        @driver.find_element(:id, 'Pickers').click

        elements = @driver.find_elements :class, 'XCUIElementTypePickerWheel'
        assert_equal 'John Appleseed', elements[0].value

        args = { element: elements[0].ref, order: :next }
        @driver.execute_script 'mobile: selectPickerWheelValue', args
        assert_equal 'Serena Auroux', elements[0].value

        args = { element: elements[0].ref, order: :previous }
        @driver.execute_script 'mobile: selectPickerWheelValue', args
        assert_equal 'John Appleseed', elements[0].value
      end

      def test_pasteboard
        @driver ||= @core.start_driver

        message = 'happy appium'

        args = { content: message }
        @driver.execute_script 'mobile: setPasteboard', args
        assert_equal message, @driver.get_clipboard

        # Base64 which follows RFC 2045 inserts new line every 60 chars
        # Ruby client sends it as RFC 4648 (Base64.strict_encode64)
        message = 'ハッピー testing GgoAAAANSUhEUgAAAu4AAAU2CAIAAABFtaRRAAAAAXNSR0IArs4c6QAAABxpRE9UAAAAAgAAAAAAAA'
        args = { content: message, encoding: 'utf-8' }
        @driver.execute_script 'mobile: setPasteboard', args

        # Ruby decode the string as ASCII-8BIT in Base64.encode64
        assert_equal message, @driver.get_clipboard.force_encoding('utf-8')
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
        assert [:running_in_background_suspended, :not_running].include? siri_state

        @driver.execute_script 'mobile: siriCommand', { text: 'hello, siri' }

        e = @core.wait { @driver.find_element :accessibility_id, 'hello, siri' }
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
end
