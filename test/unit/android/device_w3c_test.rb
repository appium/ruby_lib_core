require 'test_helper'
require 'webmock/minitest'

# $ rake test:unit TEST=test/unit/android/device_test.rb
class AppiumLibCoreTest
  module Android
    class DeviceW3CTest < Minitest::Test
      include AppiumLibCoreTest::Mock

      def setup
        @core ||= ::Appium::Core.for(self, Caps::ANDROID_OPS)
        @driver ||= android_mock_create_session_w3c
      end

      def parameterized_method_defined_check(array)
        array.each { |v| assert ::Appium::Core::Base::Bridge::W3C.method_defined?(v) }
      end

      def test_no_arg_definitions
        parameterized_method_defined_check([:shake,
                                            :launch_app,
                                            :close_app,
                                            :reset,
                                            :device_locked?,
                                            :unlock,
                                            :device_time,
                                            :current_context,
                                            :open_notifications,
                                            :toggle_airplane_mode,
                                            :current_activity,
                                            :current_package,
                                            :get_system_bars,
                                            :get_display_density,
                                            :is_keyboard_shown,
                                            :get_network_connection,
                                            :get_performance_data_types])
      end

      def test_with_arg_definitions
        parameterized_method_defined_check([:available_contexts,
                                            :set_context,
                                            :app_strings,
                                            :lock,
                                            :install_app,
                                            :remove_app,
                                            :app_installed?,
                                            :terminate_app,
                                            :activate_app,
                                            :app_state,
                                            :background_app,
                                            :hide_keyboard,
                                            :keyevent,
                                            :press_keycode,
                                            :long_press_keycode,
                                            :take_element_screenshot,
                                            :set_immediate_value,
                                            :replace_value,
                                            :push_file,
                                            :pull_file,
                                            :pull_folder,
                                            :get_settings,
                                            :update_settings,
                                            :touch_actions,
                                            :multi_touch,
                                            :start_activity,
                                            :end_coverage,
                                            :set_network_connection,
                                            :get_performance_data])
      end

      ## no args

      def test_delete
        stub_request(:delete, SESSION)
          .to_return(headers: HEADER, status: 200, body: { value: nil }.to_json)

        @driver.quit

        assert_requested(:delete, SESSION, times: 1)
      end

      def test_shake
        stub_request(:post, "#{SESSION}/appium/device/shake")
          .to_return(headers: HEADER, status: 200, body: { value: nil }.to_json)

        @driver.shake

        assert_requested(:post, "#{SESSION}/appium/device/shake", times: 1)
      end

      def test_launch_app
        stub_request(:post, "#{SESSION}/appium/app/launch")
          .to_return(headers: HEADER, status: 200, body: { value: nil }.to_json)

        @driver.launch_app

        assert_requested(:post, "#{SESSION}/appium/app/launch", times: 1)
      end

      def test_close_app
        stub_request(:post, "#{SESSION}/appium/app/close")
          .to_return(headers: HEADER, status: 200, body: { value: nil }.to_json)

        @driver.close_app

        assert_requested(:post, "#{SESSION}/appium/app/close", times: 1)
      end

      def test_reset
        stub_request(:post, "#{SESSION}/appium/app/reset")
          .to_return(headers: HEADER, status: 200, body: { value: nil }.to_json)

        @driver.reset

        assert_requested(:post, "#{SESSION}/appium/app/reset", times: 1)
      end

      def test_device_locked?
        stub_request(:post, "#{SESSION}/appium/device/is_locked")
          .to_return(headers: HEADER, status: 200, body: { value: 'true' }.to_json)

        @driver.device_locked?

        assert_requested(:post, "#{SESSION}/appium/device/is_locked", times: 1)
      end

      def test_unlock
        stub_request(:post, "#{SESSION}/appium/device/unlock")
          .to_return(headers: HEADER, status: 200, body: { value: nil }.to_json)

        @driver.unlock

        assert_requested(:post, "#{SESSION}/appium/device/unlock", times: 1)
      end

      def test_device_time
        stub_request(:get, "#{SESSION}/appium/device/system_time")
          .to_return(headers: HEADER, status: 200, body: { value: 'device time' }.to_json)

        @driver.device_time

        assert_requested(:get, "#{SESSION}/appium/device/system_time", times: 1)
      end

      def test_current_context
        stub_request(:get, "#{SESSION}/context")
          .to_return(headers: HEADER, status: 200, body: { value: 'A' }.to_json)

        @driver.current_context

        assert_requested(:get, "#{SESSION}/context", times: 1)
      end

      def test_open_notifications
        stub_request(:post, "#{SESSION}/appium/device/open_notifications")
          .to_return(headers: HEADER, status: 200, body: { value: nil }.to_json)

        @driver.open_notifications

        assert_requested(:post, "#{SESSION}/appium/device/open_notifications", times: 1)
      end

      def test_toggle_airplane_mode
        stub_request(:post, "#{SESSION}/appium/device/toggle_airplane_mode")
          .to_return(headers: HEADER, status: 200, body: { value: nil }.to_json)

        @driver.toggle_airplane_mode

        assert_requested(:post, "#{SESSION}/appium/device/toggle_airplane_mode", times: 1)
      end

      def test_current_activity
        stub_request(:get, "#{SESSION}/appium/device/current_activity")
          .to_return(headers: HEADER, status: 200, body: { value: 'A' }.to_json)

        @driver.current_activity

        assert_requested(:get, "#{SESSION}/appium/device/current_activity", times: 1)
      end

      def test_current_package
        stub_request(:get, "#{SESSION}/appium/device/current_package")
          .to_return(headers: HEADER, status: 200, body: { value: 'A' }.to_json)

        @driver.current_package

        assert_requested(:get, "#{SESSION}/appium/device/current_package", times: 1)
      end

      def test_get_system_bars
        stub_request(:get, "#{SESSION}/appium/device/system_bars")
          .to_return(headers: HEADER, status: 200, body: { value: 'A' }.to_json)

        @driver.get_system_bars

        assert_requested(:get, "#{SESSION}/appium/device/system_bars", times: 1)
      end

      def test_get_display_density
        stub_request(:get, "#{SESSION}/appium/device/display_density")
          .to_return(headers: HEADER, status: 200, body: { value: 'A' }.to_json)

        @driver.get_display_density

        assert_requested(:get, "#{SESSION}/appium/device/display_density", times: 1)
      end

      def test_is_keyboard_shown
        stub_request(:get, "#{SESSION}/appium/device/is_keyboard_shown")
          .to_return(headers: HEADER, status: 200, body: { value: 'A' }.to_json)

        @driver.is_keyboard_shown

        assert_requested(:get, "#{SESSION}/appium/device/is_keyboard_shown", times: 1)
      end

      def test_get_network_connection
        stub_request(:get, "#{SESSION}/network_connection")
          .to_return(headers: HEADER, status: 200, body: { value: 'A' }.to_json)

        @driver.get_network_connection

        assert_requested(:get, "#{SESSION}/network_connection", times: 1)
      end

      def test_get_performance_data_types
        stub_request(:post, "#{SESSION}/appium/performanceData/types")
          .to_return(headers: HEADER, status: 200, body: { value: ['a'] }.to_json)

        @driver.get_performance_data_types

        assert_requested(:post, "#{SESSION}/appium/performanceData/types", times: 1)
      end

      ## with args

      def test_available_contexts
        stub_request(:get, "#{SESSION}/contexts")
          .to_return(headers: HEADER, status: 200, body: { value: '' }.to_json)

        @driver.available_contexts

        assert_requested(:get, "#{SESSION}/contexts", times: 1)
      end

      def test_set_context
        stub_request(:post, "#{SESSION}/context")
          .to_return(headers: HEADER, status: 200, body: { value: '' }.to_json)

        @driver.set_context 'NATIVE_APP'

        assert_requested(:post, "#{SESSION}/context", times: 1)
      end

      def test_app_strings
        stub_request(:post, "#{SESSION}/appium/app/strings")
          .to_return(headers: HEADER, status: 200, body: { value: 'xxxx' }.to_json)

        @driver.app_strings

        assert_requested(:post, "#{SESSION}/appium/app/strings", times: 1)
      end

      def test_lock
        stub_request(:post, "#{SESSION}/appium/device/lock")
          .to_return(headers: HEADER, status: 200, body: { value: '' }.to_json)

        @driver.lock 5

        assert_requested(:post, "#{SESSION}/appium/device/lock", times: 1)
      end

      def test_terminate_app
        stub_request(:post, "#{SESSION}/appium/device/terminate_app")
          .to_return(headers: HEADER, status: 200, body: { value: true }.to_json)

        @driver.terminate_app 'com.app.id'

        assert_requested(:post, "#{SESSION}/appium/device/terminate_app", times: 1)
      end

      def test_terminate_app_with_param
        stub_request(:post, "#{SESSION}/appium/device/terminate_app")
          .with(body: { appId: 'com.app.id', options: { timeout: 20_000 } }.to_json)
          .to_return(headers: HEADER, status: 200, body: { value: true }.to_json)

        @driver.terminate_app 'com.app.id', timeout: 20_000

        assert_requested(:post, "#{SESSION}/appium/device/terminate_app", times: 1)
      end

      def test_activate_app
        stub_request(:post, "#{SESSION}/appium/device/activate_app")
          .to_return(headers: HEADER, status: 200, body: { value: '' }.to_json)

        @driver.activate_app 'com.app.id'

        assert_requested(:post, "#{SESSION}/appium/device/activate_app", times: 1)
      end

      def test_app_state
        stub_request(:post, "#{SESSION}/appium/device/app_state")
          .to_return(headers: HEADER, status: 200, body: { value: '' }.to_json)

        @driver.app_state 'com.app.id'

        assert_requested(:post, "#{SESSION}/appium/device/app_state", times: 1)
      end

      def test_install_app
        stub_request(:post, "#{SESSION}/appium/device/install_app")
          .to_return(headers: HEADER, status: 200, body: { value: '' }.to_json)

        @driver.install_app 'app_path'

        assert_requested(:post, "#{SESSION}/appium/device/install_app", times: 1)
      end

      def test_install_app_with_params
        stub_request(:post, "#{SESSION}/appium/device/install_app")
          .with(body: { appPath: 'app_path',
                        options: {
                          replace: true,
                          timeout: 20_000,
                          allowTestPackages: true,
                          useSdcard: false,
                          grantPermissions: false
                        } }.to_json)
          .to_return(headers: HEADER, status: 200, body: { value: '' }.to_json)

        @driver.install_app 'app_path',
                            replace: true,
                            timeout: 20_000,
                            allow_test_packages: true,
                            use_sdcard: false,
                            grant_permissions: false

        assert_requested(:post, "#{SESSION}/appium/device/install_app", times: 1)
      end

      def test_remove_app
        stub_request(:post, "#{SESSION}/appium/device/remove_app")
          .to_return(headers: HEADER, status: 200, body: { value: '' }.to_json)

        @driver.remove_app 'com.app.id'

        assert_requested(:post, "#{SESSION}/appium/device/remove_app", times: 1)
      end

      def test_remove_app_with_param
        stub_request(:post, "#{SESSION}/appium/device/remove_app")
          .with(body: { appId: 'com.app.id', options: { keepData: false, timeout: 20_000 } }.to_json)
          .to_return(headers: HEADER, status: 200, body: { value: '' }.to_json)

        @driver.remove_app 'com.app.id', keep_data: false, timeout: 20_000

        assert_requested(:post, "#{SESSION}/appium/device/remove_app", times: 1)
      end

      def test_app_installed?
        stub_request(:post, "#{SESSION}/appium/device/app_installed")
          .to_return(headers: HEADER, status: 200, body: { value: '' }.to_json)

        @driver.app_installed? 'com.app.id'

        assert_requested(:post, "#{SESSION}/appium/device/app_installed", times: 1)
      end

      def test_background_app
        stub_request(:post, "#{SESSION}/appium/app/background")
          .to_return(headers: HEADER, status: 200, body: { value: '' }.to_json)

        @driver.background_app 0

        assert_requested(:post, "#{SESSION}/appium/app/background", times: 1)
      end

      def test_hide_keyboard
        stub_request(:post, "#{SESSION}/appium/device/hide_keyboard")
          .to_return(headers: HEADER, status: 200, body: { value: '' }.to_json)

        @driver.hide_keyboard 'Finished'

        assert_requested(:post, "#{SESSION}/appium/device/hide_keyboard", times: 1)
      end

      def test_keyevent
        # only for Selendroid
        stub_request(:post, "#{SESSION}/appium/device/keyevent")
          .to_return(headers: HEADER, status: 200, body: { value: '' }.to_json)

        @driver.keyevent 86

        assert_requested(:post, "#{SESSION}/appium/device/keyevent", times: 1)
      end

      def test_press_keycode
        stub_request(:post, "#{SESSION}/appium/device/press_keycode")
          .to_return(headers: HEADER, status: 200, body: { value: '' }.to_json)

        @driver.press_keycode 86

        assert_requested(:post, "#{SESSION}/appium/device/press_keycode", times: 1)
      end

      def test_long_press_keycode
        stub_request(:post, "#{SESSION}/appium/device/long_press_keycode")
          .to_return(headers: HEADER, status: 200, body: { value: '' }.to_json)

        @driver.long_press_keycode 86

        assert_requested(:post, "#{SESSION}/appium/device/long_press_keycode", times: 1)
      end

      def test_take_element_screenshot
        stub_request(:get, "#{SESSION}/element/id/screenshot")
          .to_return(headers: HEADER, status: 200, body: { value: '' }.to_json)

        @driver.take_element_screenshot ::Selenium::WebDriver::Element.new(@driver.send(:bridge), 'id'), 'sample.png'

        assert_requested(:get, "#{SESSION}/element/id/screenshot", times: 1)
      end

      def test_set_immediate_value
        stub_request(:post, "#{SESSION}/appium/element/id/value")
          .to_return(headers: HEADER, status: 200, body: { value: '' }.to_json)

        @driver.set_immediate_value ::Selenium::WebDriver::Element.new(@driver.send(:bridge), 'id'), 'value'

        assert_requested(:post, "#{SESSION}/appium/element/id/value", times: 1)
      end

      def test_replace_value
        stub_request(:post, "#{SESSION}/appium/element/id/replace_value")
          .to_return(headers: HEADER, status: 200, body: { value: '' }.to_json)

        @driver.replace_value ::Selenium::WebDriver::Element.new(@driver.send(:bridge), 'id'), 'value'

        assert_requested(:post, "#{SESSION}/appium/element/id/replace_value", times: 1)
      end

      def test_push_file
        stub_request(:post, "#{SESSION}/appium/device/push_file")
          .to_return(headers: HEADER, status: 200, body: { value: '' }.to_json)

        @driver.push_file 'path/to/save/data', 'data'

        assert_requested(:post, "#{SESSION}/appium/device/push_file", times: 1)
      end

      def test_pull_file
        stub_request(:post, "#{SESSION}/appium/device/pull_file")
          .to_return(headers: HEADER, status: 200, body: { value: '' }.to_json)

        @driver.pull_file 'path/to/save/data'

        assert_requested(:post, "#{SESSION}/appium/device/pull_file", times: 1)
      end

      def test_pull_folder
        stub_request(:post, "#{SESSION}/appium/device/pull_folder")
          .to_return(headers: HEADER, status: 200, body: { value: '' }.to_json)

        @driver.pull_folder 'path/to/save/data'

        assert_requested(:post, "#{SESSION}/appium/device/pull_folder", times: 1)
      end

      def test_get_settings
        stub_request(:get, "#{SESSION}/appium/settings")
          .to_return(headers: HEADER, status: 200, body: { value: '' }.to_json)

        @driver.get_settings

        assert_requested(:get, "#{SESSION}/appium/settings", times: 1)
      end

      def test_update_settings
        stub_request(:post, "#{SESSION}/appium/settings")
          .to_return(headers: HEADER, status: 200, body: { value: '' }.to_json)

        @driver.update_settings(sample: 'value')

        assert_requested(:post, "#{SESSION}/appium/settings", times: 1)
      end

      def test_touch_actions
        stub_request(:post, "#{SESSION}/touch/perform")
          .to_return(headers: HEADER, status: 200, body: { value: '' }.to_json)

        @driver.touch_actions 'actions'

        assert_requested(:post, "#{SESSION}/touch/perform", times: 1)
      end

      def test_multi_touch
        stub_request(:post, "#{SESSION}/touch/multi/perform")
          .to_return(headers: HEADER, status: 200, body: { value: '' }.to_json)

        @driver.multi_touch 'actions'

        assert_requested(:post, "#{SESSION}/touch/multi/perform", times: 1)
      end

      def test_start_activity
        stub_request(:post, "#{SESSION}/appium/device/start_activity")
          .to_return(headers: HEADER, status: 200, body: { value: '' }.to_json)

        @driver.start_activity(app_activity: 'activity', app_package: 'package')

        assert_requested(:post, "#{SESSION}/appium/device/start_activity", times: 1)
      end

      def test_end_coverage
        stub_request(:post, "#{SESSION}/appium/app/end_test_coverage")
          .to_return(headers: HEADER, status: 200, body: { value: '' }.to_json)

        @driver.end_coverage 'path/to', 'intent'

        assert_requested(:post, "#{SESSION}/appium/app/end_test_coverage", times: 1)
      end

      def test_set_network_connection
        stub_request(:post, "#{SESSION}/network_connection")
          .to_return(headers: HEADER, status: 200, body: { value: '' }.to_json)

        @driver.set_network_connection 1

        assert_requested(:post, "#{SESSION}/network_connection", times: 1)
      end

      def test_get_perfoemance_data
        stub_request(:post, "#{SESSION}/appium/getPerformanceData")
          .to_return(headers: HEADER, status: 200, body: { value: '' }.to_json)

        @driver.get_performance_data(package_name: 'package_name', data_type: 'type')

        assert_requested(:post, "#{SESSION}/appium/getPerformanceData", times: 1)
      end

      def test_start_recording_screen_default
        stub_request(:post, "#{SESSION}/appium/start_recording_screen")
          .with(body: { options: { timeLimit: '180', bitRate: '4000000' } }.to_json)
          .to_return(headers: HEADER, status: 200, body: { value: ['a'] }.to_json)

        @driver.start_recording_screen

        assert_requested(:post, "#{SESSION}/appium/start_recording_screen", times: 1)
      end

      def test_start_recording_screen_custom
        stub_request(:post, "#{SESSION}/appium/start_recording_screen")
          .with(body: { options: { videoSize: '1280x1280', timeLimit: '60', bitRate: '5000000' } }.to_json)
          .to_return(headers: HEADER, status: 200, body: { value: ['a'] }.to_json)

        @driver.start_recording_screen video_size: '1280x1280', time_limit: '60', bit_rate: '5000000'

        assert_requested(:post, "#{SESSION}/appium/start_recording_screen", times: 1)
      end

      def test_stop_recording_screen_default
        stub_request(:post, "#{SESSION}/appium/stop_recording_screen")
          .with(body: {}.to_json)
          .to_return(headers: HEADER, status: 200, body: { value: ['a'] }.to_json)

        @driver.stop_recording_screen

        assert_requested(:post, "#{SESSION}/appium/stop_recording_screen", times: 1)
      end

      def test_stop_recording_screen_custom
        stub_request(:post, "#{SESSION}/appium/stop_recording_screen")
          .with(body: { options:
                            { remotePath: 'https://example.com', user: 'user name', pass: 'pass', method: 'PUT' } }.to_json)
          .to_return(headers: HEADER, status: 200, body: { value: ['a'] }.to_json)

        @driver.stop_recording_screen(remote_path: 'https://example.com', user: 'user name', pass: 'pass')

        assert_requested(:post, "#{SESSION}/appium/stop_recording_screen", times: 1)
      end

      # emulator
      def test_send_sms
        stub_request(:post, "#{SESSION}/appium/device/send_sms")
          .with(body: { phoneNumber: '00000000000', message: 'test message' }.to_json)
          .to_return(headers: HEADER, status: 200, body: { value: '' }.to_json)

        @driver.send_sms phone_number: '00000000000', message: 'test message'

        assert_requested(:post, "#{SESSION}/appium/device/send_sms", times: 1)
      end

      def test_gsm_call
        stub_request(:post, "#{SESSION}/appium/device/gsm_call")
          .with(body: { phoneNumber: '00000000000', action: 'call' }.to_json)
          .to_return(headers: HEADER, status: 200, body: { value: '' }.to_json)

        @driver.gsm_call phone_number: '00000000000', action: :call

        assert_requested(:post, "#{SESSION}/appium/device/gsm_call", times: 1)
      end

      def test_gsm_signal
        stub_request(:post, "#{SESSION}/appium/device/gsm_signal")
          .with(body: { signalStrengh: ::Appium::Android::Device::Emulator::GSM_SIGNALS[:good] }.to_json)
          .to_return(headers: HEADER, status: 200, body: { value: '' }.to_json)

        @driver.gsm_signal :good

        assert_requested(:post, "#{SESSION}/appium/device/gsm_signal", times: 1)
      end

      def test_gsm_voice
        stub_request(:post, "#{SESSION}/appium/device/gsm_voice")
          .with(body: { state: 'on' }.to_json)
          .to_return(headers: HEADER, status: 200, body: { value: '' }.to_json)

        @driver.gsm_voice :on

        assert_requested(:post, "#{SESSION}/appium/device/gsm_voice", times: 1)
      end

      def test_network_speed
        stub_request(:post, "#{SESSION}/appium/device/network_speed")
          .with(body: { netspeed: 'gsm' }.to_json)
          .to_return(headers: HEADER, status: 200, body: { value: '' }.to_json)

        @driver.set_network_speed :gsm

        assert_requested(:post, "#{SESSION}/appium/device/network_speed", times: 1)
      end

      def test_set_power_capacity
        stub_request(:post, "#{SESSION}/appium/device/power_capacity")
          .with(body: { percent: 10 }.to_json)
          .to_return(headers: HEADER, status: 200, body: { value: '' }.to_json)

        @driver.set_power_capacity 10

        assert_requested(:post, "#{SESSION}/appium/device/power_capacity", times: 1)
      end

      def test_power_ac
        stub_request(:post, "#{SESSION}/appium/device/power_ac")
          .with(body: { state: 'on' }.to_json)
          .to_return(headers: HEADER, status: 200, body: { value: '' }.to_json)

        @driver.set_power_ac :on

        assert_requested(:post, "#{SESSION}/appium/device/power_ac", times: 1)
      end
    end
  end
end
