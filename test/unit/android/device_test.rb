require 'test_helper'
require 'webmock/minitest'

# $ rake android TEST=test/android/android/device_test.rb
class AppiumLibCoreTest
  module Android
    class DeviceTest < Minitest::Test
      HEADER = { 'Content-Type' => 'application/json; charset=utf-8', 'Cache-Control' => 'no-cache' }.freeze
      SESSION = 'http://127.0.0.1:4723/wd/hub/session/1234567890'.freeze

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

      def test_install_app
        stub_request(:post, "#{SESSION}/appium/device/install_app")
          .to_return(headers: HEADER, status: 200, body: { value: '' }.to_json)

        @driver.install_app 'app_path'

        assert_requested(:post, "#{SESSION}/appium/device/install_app", times: 1)
      end

      def test_remove_app
        stub_request(:post, "#{SESSION}/appium/device/remove_app")
          .to_return(headers: HEADER, status: 200, body: { value: '' }.to_json)

        @driver.remove_app 'com.app.id'

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

        @driver.update_settings({ sample: 'value' })

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

        @driver.start_activity({ app_activity: 'activity', app_package: 'package' })

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
