require 'test_helper'
require 'webmock/minitest'

# $ rake android TEST=test/android/android/device_test.rb
class AppiumLibCoreTest
  module Android
    class DeviceTest < Minitest::Test
      HEADER = { 'Content-Type' => 'application/json; charset=utf-8', 'Cache-Control' => 'no-cache' }

      def setup
        @core ||= ::Appium::Core.for(self, Caps::ANDROID_OPS)
        @driver ||= mock_create_session
      end

      def parameterized_method_defined_check(array)
        array.each { |v| assert ::Appium::Core::Base::CoreBridgeOSS.method_defined?(v) }
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
                                            :start_activity,
                                            :end_coverage,
                                            :set_network_connection,
                                            :get_performance_data])
      end

      ## no args

      def test_delete
        stub_request(:delete, 'http://127.0.0.1:4723/wd/hub/session/1234567890')
          .to_return(headers: HEADER, status: 200, body: { value: nil }.to_json)

        @driver.quit

        assert_requested(:delete, 'http://127.0.0.1:4723/wd/hub/session/1234567890', times: 1)
      end

      def test_shake
        stub_request(:post, 'http://127.0.0.1:4723/wd/hub/session/1234567890/appium/device/shake')
            .to_return(headers: HEADER, status: 200, body: { value: nil }.to_json)

        @driver.shake

        assert_requested(:post, 'http://127.0.0.1:4723/wd/hub/session/1234567890/appium/device/shake', times: 1)
      end

      def test_launch_app
        stub_request(:post, 'http://127.0.0.1:4723/wd/hub/session/1234567890/appium/app/launch')
          .to_return(headers: HEADER, status: 200, body: { value: nil }.to_json)

        @driver.launch_app

        assert_requested(:post, 'http://127.0.0.1:4723/wd/hub/session/1234567890/appium/app/launch', times: 1)
      end

      def test_close_app
        stub_request(:post, 'http://127.0.0.1:4723/wd/hub/session/1234567890/appium/app/close')
          .to_return(headers: HEADER, status: 200, body: { value: nil }.to_json)

        @driver.close_app

        assert_requested(:post, 'http://127.0.0.1:4723/wd/hub/session/1234567890/appium/app/close', times: 1)
      end

      def test_reset
        stub_request(:post, 'http://127.0.0.1:4723/wd/hub/session/1234567890/appium/app/reset')
          .to_return(headers: HEADER, status: 200, body: { value: nil }.to_json)

        @driver.reset

        assert_requested(:post, 'http://127.0.0.1:4723/wd/hub/session/1234567890/appium/app/reset', times: 1)
      end

      def test_device_locked?
        stub_request(:post, 'http://127.0.0.1:4723/wd/hub/session/1234567890/appium/device/is_locked')
          .to_return(headers: HEADER, status: 200, body: { value: 'true' }.to_json)

        @driver.device_locked?

        assert_requested(:post, 'http://127.0.0.1:4723/wd/hub/session/1234567890/appium/device/is_locked', times: 1)
      end

      def test_unlock
        stub_request(:post, 'http://127.0.0.1:4723/wd/hub/session/1234567890/appium/device/unlock')
            .to_return(headers: HEADER, status: 200, body: { value: nil }.to_json)

        @driver.unlock

        assert_requested(:post, 'http://127.0.0.1:4723/wd/hub/session/1234567890/appium/device/unlock', times: 1)
      end

      def test_device_time
        stub_request(:get, 'http://127.0.0.1:4723/wd/hub/session/1234567890/appium/device/system_time')
          .to_return(headers: HEADER, status: 200, body: { value: 'device time' }.to_json)

        @driver.device_time

        assert_requested(:get, 'http://127.0.0.1:4723/wd/hub/session/1234567890/appium/device/system_time', times: 1)
      end

      def test_current_context
        stub_request(:get, 'http://127.0.0.1:4723/wd/hub/session/1234567890/context')
          .to_return(headers: HEADER, status: 200, body: { value: 'A' }.to_json)

        @driver.current_context

        assert_requested(:get, 'http://127.0.0.1:4723/wd/hub/session/1234567890/context', times: 1)
      end

      def test_open_notifications
        stub_request(:post, 'http://127.0.0.1:4723/wd/hub/session/1234567890/appium/device/open_notifications')
          .to_return(headers: HEADER, status: 200, body: { value: nil }.to_json)

        @driver.open_notifications

        assert_requested(:post, 'http://127.0.0.1:4723/wd/hub/session/1234567890/appium/device/open_notifications', times: 1)
      end

      def test_toggle_airplane_mode
        stub_request(:post, 'http://127.0.0.1:4723/wd/hub/session/1234567890/appium/device/toggle_airplane_mode')
          .to_return(headers: HEADER, status: 200, body: { value: nil }.to_json)

        @driver.toggle_airplane_mode

        assert_requested(:post, 'http://127.0.0.1:4723/wd/hub/session/1234567890/appium/device/toggle_airplane_mode', times: 1)
      end

      def test_current_activity
        stub_request(:get, 'http://127.0.0.1:4723/wd/hub/session/1234567890/appium/device/current_activity')
            .to_return(headers: HEADER, status: 200, body: { value: 'A' }.to_json)

        @driver.current_activity

        assert_requested(:get, 'http://127.0.0.1:4723/wd/hub/session/1234567890/appium/device/current_activity', times: 1)
      end

      def test_current_package
        stub_request(:get, 'http://127.0.0.1:4723/wd/hub/session/1234567890/appium/device/current_package')
            .to_return(headers: HEADER, status: 200, body: { value: 'A' }.to_json)

        @driver.current_package

        assert_requested(:get, 'http://127.0.0.1:4723/wd/hub/session/1234567890/appium/device/current_package', times: 1)
      end

      def test_get_system_bars
        stub_request(:get, 'http://127.0.0.1:4723/wd/hub/session/1234567890/appium/device/system_bars')
            .to_return(headers: HEADER, status: 200, body: { value: 'A' }.to_json)

        @driver.get_system_bars

        assert_requested(:get, 'http://127.0.0.1:4723/wd/hub/session/1234567890/appium/device/system_bars', times: 1)
      end

      def test_get_display_density
        stub_request(:get, 'http://127.0.0.1:4723/wd/hub/session/1234567890/appium/device/display_density')
          .to_return(headers: HEADER, status: 200, body: { value: 'A' }.to_json)

        @driver.get_display_density

        assert_requested(:get, 'http://127.0.0.1:4723/wd/hub/session/1234567890/appium/device/display_density', times: 1)
      end

      def test_is_keyboard_shown
        stub_request(:get, 'http://127.0.0.1:4723/wd/hub/session/1234567890/appium/device/is_keyboard_shown')
            .to_return(headers: HEADER, status: 200, body: { value: 'A' }.to_json)

        @driver.is_keyboard_shown

        assert_requested(:get, 'http://127.0.0.1:4723/wd/hub/session/1234567890/appium/device/is_keyboard_shown', times: 1)
      end

      def test_get_network_connection
        stub_request(:get, 'http://127.0.0.1:4723/wd/hub/session/1234567890/network_connection')
            .to_return(headers: HEADER, status: 200, body: { value: 'A' }.to_json)

        @driver.get_network_connection

        assert_requested(:get, 'http://127.0.0.1:4723/wd/hub/session/1234567890/network_connection', times: 1)
      end

      def test_get_performance_data_types
        stub_request(:post, 'http://127.0.0.1:4723/wd/hub/session/1234567890/appium/performanceData/types')
            .to_return(headers: HEADER, status: 200, body: { value: ['a'] }.to_json)

        @driver.get_performance_data_types

        assert_requested(:post, 'http://127.0.0.1:4723/wd/hub/session/1234567890/appium/performanceData/types', times: 1)
      end

      ## with args

      private

      def mock_create_session
        response = {
          value: {
            sessionId: '1234567890',
            capabilities: {
              platform: 'LINUX',
              webStorageEnabled: false,
              takesScreenshot: true,
              javascriptEnabled: true,
              databaseEnabled: false,
              networkConnectionEnabled: true,
              locationContextEnabled: false,
              warnings: {},
              desired: {
                platformName: 'Android',
                platformVersion: '7.1.1',
                deviceName: 'Android Emulator',
                app: '/test/apps/ApiDemos-debug.apk',
                newCommandTimeout: 240,
                unicodeKeyboard: true,
                resetKeyboard: true
              },
              platformName: 'Android',
              platformVersion: '7.1.1',
              deviceName: 'emulator-5554',
              app: '/test/apps/ApiDemos-debug.apk',
              newCommandTimeout: 240,
              unicodeKeyboard: true,
              resetKeyboard: true,
              deviceUDID: 'emulator-5554',
              deviceScreenSize: '1080x1920',
              deviceModel: 'Android SDK built for x86_64',
              deviceManufacturer: 'unknown',
              appPackage: 'com.example.android.apis',
              appWaitPackage: 'com.example.android.apis',
              appActivity: 'com.example.android.apis.ApiDemos',
              appWaitActivity: 'com.example.android.apis.ApiDemos'
            }
          }
        }.to_json

        stub_request(:post, 'http://127.0.0.1:4723/wd/hub/session')
          .to_return(headers: HEADER, status: 200, body: response)

        stub_request(:post, 'http://127.0.0.1:4723/wd/hub/session/1234567890/timeouts')
          .with(body: { implicit: 30_000 }.to_json)
          .to_return(headers: HEADER, status: 200, body: { value: nil }.to_json)

        driver = @core.start_driver

        assert_requested(:post, 'http://127.0.0.1:4723/wd/hub/session', times: 1)
        assert_requested(:post, 'http://127.0.0.1:4723/wd/hub/session/1234567890/timeouts', times: 1)

        assert_equal '1234567890', driver.session_id

        driver
      end
    end
  end
end
