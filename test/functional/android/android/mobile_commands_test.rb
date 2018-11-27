require 'test_helper'

# $ rake test:func:ios TEST=test/functional/android/android/mobile_commands_test.rb
class AppiumLibCoreTest
  module Android
    class MobileCommandsTest < AppiumLibCoreTest::Function::TestCase
      def setup
        @core = ::Appium::Core.for(Caps.android)
        @driver = @core.start_driver
      end

      def teardown
        save_reports(@driver)
      end

      # @since Appium 1.10.0
      def test_toast
        skip unless @core.automation_name == :espresso

        @driver.find_element(:accessibility_id, 'Views').click
        @driver.find_element(:accessibility_id, 'Secure View').click
        @driver.find_element(:id, 'id/secure_view_toast_button').click

        assert @driver.execute_script 'mobile: isToastVisible', { text: 'A toast', isRegexp: true }

        sleep 5 # wait for disappearing the toast
        assert !@driver.execute_script('mobile: isToastVisible', { text: 'A toast', isRegexp: true })
      end
    end
  end
end
