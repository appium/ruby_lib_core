require 'test_helper'
require 'webmock/minitest'

# $ rake test:unit TEST=test/unit/ios/device_test.rb
class AppiumLibCoreTest
  module IOS
    class DeviceTest < Minitest::Test
      include AppiumLibCoreTest::Mock

      def setup
        @core ||= ::Appium::Core.for(self, Caps::IOS_OPS)
        @driver ||= ios_mock_create_session
      end

      def parameterized_method_defined_check(array)
        array.each { |v| assert ::Appium::Core::Base::CoreBridgeOSS.method_defined?(v) }
        array.each { |v| assert ::Appium::Core::Base::CoreBridgeW3C.method_defined?(v) }
      end

      def test_no_arg_definitions
        parameterized_method_defined_check([:shake,
                                            :launch_app,
                                            :close_app,
                                            :reset,
                                            :device_locked?,
                                            :unlock,
                                            :device_time,
                                            :current_context])
      end

      def test_with_arg_definitions
        parameterized_method_defined_check([:available_contexts,
                                            :set_context,
                                            :app_strings,
                                            :lock,
                                            :install_app,
                                            :remove_app,
                                            :app_installed?,
                                            :background_app,
                                            :hide_keyboard,
                                            :press_keycode,
                                            :long_press_keycode,
                                            :set_immediate_value,
                                            :push_file,
                                            :pull_file,
                                            :pull_folder,
                                            :get_settings,
                                            :update_settings,
                                            :touch_actions,
                                            :multi_touch,
                                            :touch_id,
                                            :toggle_touch_id_enrollment])
      end

      ## Only iOS specific methods
      ## with args

      def test_touch_id
        stub_request(:post, "#{SESSION}/appium/simulator/touch_id")
          .to_return(headers: HEADER, status: 200, body: { value: nil }.to_json)

        @driver.touch_id

        assert_requested(:post, "#{SESSION}/appium/simulator/touch_id", times: 1)
      end

      def test_toggle_touch_id_enrollment
        stub_request(:post, "#{SESSION}/appium/simulator/toggle_touch_id_enrollment")
          .to_return(headers: HEADER, status: 200, body: { value: nil }.to_json)

        @driver.toggle_touch_id_enrollment(true)

        assert_requested(:post, "#{SESSION}/appium/simulator/toggle_touch_id_enrollment", times: 1)
      end
    end
  end
end
